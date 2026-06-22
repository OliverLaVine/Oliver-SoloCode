package com.monitor.service;

import com.monitor.entity.AlertRecord;

import java.time.LocalDateTime;
import java.util.List;

public interface AlertRecordService {

    void saveAlertRecords(List<AlertRecord> alertRecords);

    List<AlertRecord> getRecentAlerts(int limit);

    List<AlertRecord> getAlertsByTimeRange(LocalDateTime startTime, LocalDateTime endTime);
}
