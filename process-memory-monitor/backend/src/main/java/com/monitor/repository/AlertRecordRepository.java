package com.monitor.repository;

import com.monitor.entity.AlertRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AlertRecordRepository extends JpaRepository<AlertRecord, Long> {

    List<AlertRecord> findByCreateTimeBetweenOrderByCreateTimeDesc(LocalDateTime startTime, LocalDateTime endTime);

    List<AlertRecord> findTop20ByOrderByCreateTimeDesc();
}
