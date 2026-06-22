package com.monitor.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "process_memory_log")
public class ProcessMemoryLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "process_id", nullable = false)
    private Integer processId;

    @Column(name = "process_name", nullable = false, length = 200)
    private String processName;

    @Column(name = "memory_usage_bytes", nullable = false)
    private Long memoryUsageBytes;

    @Column(name = "memory_usage_mb", nullable = false)
    private Double memoryUsageMb;

    @Column(name = "memory_percent", nullable = false)
    private Double memoryPercent;

    @Column(name = "is_alert", nullable = false)
    private Boolean isAlert;

    @Column(name = "create_time", nullable = false)
    private LocalDateTime createTime;

    @PrePersist
    protected void onCreate() {
        if (createTime == null) {
            createTime = LocalDateTime.now();
        }
    }
}
