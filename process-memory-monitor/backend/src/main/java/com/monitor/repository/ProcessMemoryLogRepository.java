package com.monitor.repository;

import com.monitor.entity.ProcessMemoryLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ProcessMemoryLogRepository extends JpaRepository<ProcessMemoryLog, Long> {

    List<ProcessMemoryLog> findByCreateTimeBetweenOrderByCreateTimeDesc(LocalDateTime startTime, LocalDateTime endTime);

    @Query(value = "SELECT p.* FROM process_memory_log p " +
            "WHERE p.create_time = (SELECT MAX(create_time) FROM process_memory_log) " +
            "ORDER BY p.memory_usage_bytes DESC",
            nativeQuery = true)
    List<ProcessMemoryLog> findLatestLogs();

    @Query("SELECT DISTINCT p.createTime FROM ProcessMemoryLog p ORDER BY p.createTime DESC")
    List<LocalDateTime> findDistinctCreateTimes();

    List<ProcessMemoryLog> findByProcessIdAndCreateTimeBetweenOrderByCreateTimeAsc(
            Integer processId, LocalDateTime startTime, LocalDateTime endTime);

    @Query(value = "SELECT * FROM process_memory_log p " +
            "WHERE p.is_alert = true " +
            "ORDER BY p.create_time DESC " +
            "LIMIT :limit",
            nativeQuery = true)
    List<ProcessMemoryLog> findRecentAlertLogs(@Param("limit") int limit);
}
