package com.monitor.service.impl;

import com.monitor.dto.ProcessInfoDTO;
import com.monitor.entity.ProcessMemoryLog;
import com.monitor.repository.ProcessMemoryLogRepository;
import com.monitor.service.ProcessMemoryLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class ProcessMemoryLogServiceImpl implements ProcessMemoryLogService {

    @Autowired
    private ProcessMemoryLogRepository processMemoryLogRepository;

    @Override
    @Transactional
    public void saveProcessLogs(List<ProcessInfoDTO> processList) {
        if (processList == null || processList.isEmpty()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        List<ProcessMemoryLog> logs = new ArrayList<>();

        for (ProcessInfoDTO process : processList) {
            ProcessMemoryLog logEntity = new ProcessMemoryLog();
            logEntity.setProcessId(process.getProcessId());
            logEntity.setProcessName(process.getProcessName());
            logEntity.setMemoryUsageBytes(process.getMemoryUsageBytes());
            logEntity.setMemoryUsageMb(process.getMemoryUsageMb());
            logEntity.setMemoryPercent(process.getMemoryPercent());
            logEntity.setIsAlert(process.getIsAlert());
            logEntity.setCreateTime(now);
            logs.add(logEntity);
        }

        processMemoryLogRepository.saveAll(logs);
        log.debug("保存进程内存日志 {} 条", logs.size());
    }

    @Override
    public List<ProcessMemoryLog> getLatestLogs() {
        return processMemoryLogRepository.findLatestLogs();
    }

    @Override
    public List<ProcessMemoryLog> getLogsByTimeRange(LocalDateTime startTime, LocalDateTime endTime) {
        return processMemoryLogRepository.findByCreateTimeBetweenOrderByCreateTimeDesc(startTime, endTime);
    }

    @Override
    public List<ProcessMemoryLog> getRecentAlertLogs(int limit) {
        return processMemoryLogRepository.findRecentAlertLogs(limit);
    }
}
