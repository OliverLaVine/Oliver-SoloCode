package com.monitor.service;

import com.monitor.dto.ProcessInfoDTO;
import com.monitor.entity.ProcessMemoryLog;

import java.time.LocalDateTime;
import java.util.List;

public interface ProcessMemoryLogService {

    void saveProcessLogs(List<ProcessInfoDTO> processList);

    List<ProcessMemoryLog> getLatestLogs();

    List<ProcessMemoryLog> getLogsByTimeRange(LocalDateTime startTime, LocalDateTime endTime);

    List<ProcessMemoryLog> getRecentAlertLogs(int limit);
}
