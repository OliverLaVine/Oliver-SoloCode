package com.monitor.service.impl;

import com.monitor.entity.AlertRecord;
import com.monitor.repository.AlertRecordRepository;
import com.monitor.service.AlertRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class AlertRecordServiceImpl implements AlertRecordService {

    @Autowired
    private AlertRecordRepository alertRecordRepository;

    @Override
    @Transactional
    public void saveAlertRecords(List<AlertRecord> alertRecords) {
        if (alertRecords == null || alertRecords.isEmpty()) {
            return;
        }
        alertRecordRepository.saveAll(alertRecords);
        log.info("保存告警记录 {} 条", alertRecords.size());
    }

    @Override
    public List<AlertRecord> getRecentAlerts(int limit) {
        return alertRecordRepository.findTop20ByOrderByCreateTimeDesc();
    }

    @Override
    public List<AlertRecord> getAlertsByTimeRange(LocalDateTime startTime, LocalDateTime endTime) {
        return alertRecordRepository.findByCreateTimeBetweenOrderByCreateTimeDesc(startTime, endTime);
    }
}
