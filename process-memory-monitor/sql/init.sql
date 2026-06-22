-- ============================================================
-- 进程内存监控系统 - 数据库初始化脚本
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS process_monitor
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE process_monitor;

-- ============================================================
-- 进程内存日志表
-- ============================================================
DROP TABLE IF EXISTS process_memory_log;
CREATE TABLE process_memory_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    process_id INT NOT NULL COMMENT '进程ID',
    process_name VARCHAR(200) NOT NULL COMMENT '进程名称',
    memory_usage_bytes BIGINT NOT NULL COMMENT '内存占用（字节）',
    memory_usage_mb DOUBLE NOT NULL COMMENT '内存占用（MB）',
    memory_percent DOUBLE NOT NULL COMMENT '内存占比（%）',
    is_alert TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否告警 0-否 1-是',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_process_id (process_id),
    INDEX idx_process_name (process_name),
    INDEX idx_create_time (create_time),
    INDEX idx_is_alert (is_alert)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='进程内存日志表';

-- ============================================================
-- 告警记录表
-- ============================================================
DROP TABLE IF EXISTS alert_record;
CREATE TABLE alert_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    process_id INT NOT NULL COMMENT '进程ID',
    process_name VARCHAR(200) NOT NULL COMMENT '进程名称',
    memory_usage_mb DOUBLE NOT NULL COMMENT '内存占用（MB）',
    memory_percent DOUBLE NOT NULL COMMENT '内存占比（%）',
    threshold_percent DOUBLE NOT NULL COMMENT '告警阈值（%）',
    alert_message VARCHAR(500) DEFAULT NULL COMMENT '告警信息',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_process_id (process_id),
    INDEX idx_process_name (process_name),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='告警记录表';

-- ============================================================
-- 初始化完成
-- ============================================================
SELECT '数据库初始化完成！' AS message;
