package com.monitor.controller;

import com.monitor.dto.ProcessInfoDTO;
import com.monitor.dto.Result;
import com.monitor.dto.SystemMemoryInfoDTO;
import com.monitor.entity.AlertRecord;
import com.monitor.entity.ProcessMemoryLog;
import com.monitor.service.AlertRecordService;
import com.monitor.service.ProcessMemoryLogService;
import com.monitor.service.ProcessMonitorService;
import com.monitor.service.RedisCacheService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/monitor")
@CrossOrigin(origins = "*")
public class MonitorController {

    @Autowired
    private ProcessMonitorService processMonitorService;

    @Autowired
    private ProcessMemoryLogService processMemoryLogService;

    @Autowired
    private AlertRecordService alertRecordService;

    @Autowired(required = false)
    private RedisCacheService redisCacheService;

    @GetMapping("/processes")
    public Result<List<ProcessInfoDTO>> getAllProcesses() {
        if (redisCacheService != null) {
            List<ProcessInfoDTO> cached = redisCacheService.getCachedProcessList();
            if (cached != null && !cached.isEmpty()) {
                return Result.success(cached);
            }
        }
        List<ProcessInfoDTO> processes = processMonitorService.getAllProcesses();
        return Result.success(processes);
    }

    @GetMapping("/processes/alert")
    public Result<List<ProcessInfoDTO>> getAlertProcesses() {
        if (redisCacheService != null) {
            List<ProcessInfoDTO> cached = redisCacheService.getCachedAlertProcesses();
            if (cached != null && !cached.isEmpty()) {
                return Result.success(cached);
            }
        }
        List<ProcessInfoDTO> alertProcesses = processMonitorService.getAlertProcesses();
        return Result.success(alertProcesses);
    }

    @GetMapping("/memory")
    public Result<SystemMemoryInfoDTO> getSystemMemoryInfo() {
        if (redisCacheService != null) {
            SystemMemoryInfoDTO cached = redisCacheService.getCachedSystemMemoryInfo();
            if (cached != null) {
                return Result.success(cached);
            }
        }
        SystemMemoryInfoDTO memoryInfo = processMonitorService.getSystemMemoryInfo();
        return Result.success(memoryInfo);
    }

    @GetMapping("/logs/latest")
    public Result<List<ProcessMemoryLog>> getLatestLogs() {
        List<ProcessMemoryLog> logs = processMemoryLogService.getLatestLogs();
        return Result.success(logs);
    }

    @GetMapping("/logs")
    public Result<List<ProcessMemoryLog>> getLogsByTimeRange(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime) {
        List<ProcessMemoryLog> logs = processMemoryLogService.getLogsByTimeRange(startTime, endTime);
        return Result.success(logs);
    }

    @GetMapping("/alerts/recent")
    public Result<List<AlertRecord>> getRecentAlerts(@RequestParam(defaultValue = "20") int limit) {
        List<AlertRecord> alerts = alertRecordService.getRecentAlerts(limit);
        return Result.success(alerts);
    }

    @GetMapping("/alerts")
    public Result<List<AlertRecord>> getAlertsByTimeRange(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime) {
        List<AlertRecord> alerts = alertRecordService.getAlertsByTimeRange(startTime, endTime);
        return Result.success(alerts);
    }

    @GetMapping("/alerts/logs")
    public Result<List<ProcessMemoryLog>> getRecentAlertLogs(@RequestParam(defaultValue = "50") int limit) {
        List<ProcessMemoryLog> logs = processMemoryLogService.getRecentAlertLogs(limit);
        return Result.success(logs);
    }
}
