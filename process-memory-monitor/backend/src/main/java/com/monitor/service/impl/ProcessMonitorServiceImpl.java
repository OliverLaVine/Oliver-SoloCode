package com.monitor.service.impl;

import com.monitor.config.MonitorConfig;
import com.monitor.dto.ProcessInfoDTO;
import com.monitor.dto.SystemMemoryInfoDTO;
import com.monitor.service.ProcessMonitorService;
import lombok.extern.slf4j.Slf4j;
import oshi.SystemInfo;
import oshi.hardware.GlobalMemory;
import oshi.software.os.OSProcess;
import oshi.software.os.OperatingSystem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class ProcessMonitorServiceImpl implements ProcessMonitorService {

    private final SystemInfo systemInfo = new SystemInfo();

    @Autowired
    private MonitorConfig monitorConfig;

    private OperatingSystem os;

    private GlobalMemory memory;

    @PostConstruct
    public void init() {
        this.os = systemInfo.getOperatingSystem();
        this.memory = systemInfo.getHardware().getMemory();
        log.info("进程监控服务初始化完成，系统: {}", os.toString());
    }

    @Override
    public List<ProcessInfoDTO> getAllProcesses() {
        List<OSProcess> processes = os.getProcesses();
        long totalMemory = memory.getTotal();

        return processes.stream()
                .map(process -> convertToDTO(process, totalMemory))
                .sorted(Comparator.comparingDouble(ProcessInfoDTO::getMemoryUsageBytes).reversed())
                .collect(Collectors.toList());
    }

    @Override
    public SystemMemoryInfoDTO getSystemMemoryInfo() {
        long total = memory.getTotal();
        long available = memory.getAvailable();
        long used = total - available;

        SystemMemoryInfoDTO dto = new SystemMemoryInfoDTO();
        dto.setTotalMemoryBytes(total);
        dto.setTotalMemoryGb(bytesToGB(total));
        dto.setAvailableMemoryBytes(available);
        dto.setAvailableMemoryGb(bytesToGB(available));
        dto.setUsedMemoryBytes(used);
        dto.setUsedMemoryGb(bytesToGB(used));
        dto.setUsedPercent((double) used / total * 100);

        List<ProcessInfoDTO> allProcesses = getAllProcesses();
        dto.setProcessCount(allProcesses.size());

        long alertCount = allProcesses.stream()
                .filter(ProcessInfoDTO::getIsAlert)
                .count();
        dto.setAlertProcessCount((int) alertCount);
        dto.setAlertThresholdPercent(monitorConfig.getAlert().getMemoryPercentThreshold());

        return dto;
    }

    @Override
    public List<ProcessInfoDTO> getAlertProcesses() {
        return getAllProcesses().stream()
                .filter(ProcessInfoDTO::getIsAlert)
                .collect(Collectors.toList());
    }

    private ProcessInfoDTO convertToDTO(OSProcess process, long totalMemory) {
        ProcessInfoDTO dto = new ProcessInfoDTO();
        dto.setProcessId(process.getProcessID());
        dto.setProcessName(process.getName());
        dto.setMemoryUsageBytes(process.getResidentSetSize());
        dto.setMemoryUsageMb(bytesToMB(process.getResidentSetSize()));

        double memoryPercent = (double) process.getResidentSetSize() / totalMemory * 100;
        dto.setMemoryPercent(memoryPercent);

        double threshold = monitorConfig.getAlert().getMemoryPercentThreshold();
        boolean isAlert = memoryPercent > threshold;
        dto.setIsAlert(isAlert);

        if (isAlert) {
            dto.setAlertMessage(String.format("进程 [%s] 内存占用 %.2f%% 超过阈值 %.2f%%",
                    process.getName(), memoryPercent, threshold));
        }

        return dto;
    }

    private double bytesToMB(long bytes) {
        return bytes / (1024.0 * 1024.0);
    }

    private double bytesToGB(long bytes) {
        return bytes / (1024.0 * 1024.0 * 1024.0);
    }
}
