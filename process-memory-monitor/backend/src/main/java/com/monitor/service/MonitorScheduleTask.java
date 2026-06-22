package com.monitor.service;

import com.monitor.config.MonitorConfig;
import com.monitor.dto.ProcessInfoDTO;
import com.monitor.entity.AlertRecord;
import com.monitor.service.impl.RedisCacheServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
public class MonitorScheduleTask {

    @Autowired
    private ProcessMonitorService processMonitorService;

    @Autowired
    private ProcessMemoryLogService processMemoryLogService;

    @Autowired
    private AlertRecordService alertRecordService;

    @Autowired(required = false)
    private RedisCacheService redisCacheService;

    @Autowired
    private MonitorConfig monitorConfig;

    @Scheduled(cron = "${monitor.schedule.cron}")
    public void monitorTask() {
        log.info("开始执行定时监控任务...");
        long startTime = System.currentTimeMillis();

        try {
            List<ProcessInfoDTO> allProcesses = processMonitorService.getAllProcesses();
            log.info("获取到 {} 个进程", allProcesses.size());

            processMemoryLogService.saveProcessLogs(allProcesses);

            List<ProcessInfoDTO> alertProcesses = allProcesses.stream()
                    .filter(ProcessInfoDTO::getIsAlert)
                    .collect(Collectors.toList());

            if (!alertProcesses.isEmpty()) {
                saveAlertRecords(alertProcesses);
                log.warn("检测到 {} 个进程内存占用超过阈值", alertProcesses.size());
                for (ProcessInfoDTO process : alertProcesses) {
                    log.warn("告警 - 进程: {}, PID: {}, 内存占用: {} MB, 占比: {}%",
                            process.getProcessName(),
                            process.getProcessId(),
                            String.format("%.2f", process.getMemoryUsageMb()),
                            String.format("%.2f", process.getMemoryPercent()));
                }
            }

            if (redisCacheService != null) {
                redisCacheService.cacheProcessList(allProcesses);
                redisCacheService.cacheAlertProcesses(alertProcesses);
                redisCacheService.cacheSystemMemoryInfo(processMonitorService.getSystemMemoryInfo());
            }

        } catch (Exception e) {
            log.error("定时监控任务执行失败", e);
        }

        long costTime = System.currentTimeMillis() - startTime;
        log.info("定时监控任务执行完成，耗时: {} ms", costTime);
    }

    private void saveAlertRecords(List<ProcessInfoDTO> alertProcesses) {
        List<AlertRecord> records = new ArrayList<>();
        double threshold = monitorConfig.getAlert().getMemoryPercentThreshold();

        for (ProcessInfoDTO process : alertProcesses) {
            AlertRecord record = new AlertRecord();
            record.setProcessId(process.getProcessId());
            record.setProcessName(process.getProcessName());
            record.setMemoryUsageMb(process.getMemoryUsageMb());
            record.setMemoryPercent(process.getMemoryPercent());
            record.setThresholdPercent(threshold);
            record.setAlertMessage(process.getAlertMessage());
            record.setCreateTime(LocalDateTime.now());
            records.add(record);
        }

        alertRecordService.saveAlertRecords(records);
    }
}
