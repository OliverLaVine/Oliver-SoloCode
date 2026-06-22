package com.monitor.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "monitor")
public class MonitorConfig {

    private AlertConfig alert = new AlertConfig();

    private ScheduleConfig schedule = new ScheduleConfig();

    private RedisConfig redis = new RedisConfig();

    @Data
    public static class AlertConfig {
        private double memoryPercentThreshold = 5.0;
    }

    @Data
    public static class ScheduleConfig {
        private String cron = "0 */1 * * * ?";
    }

    @Data
    public static class RedisConfig {
        private boolean enabled = true;
        private String keyPrefix = "process:monitor:";
        private long expireSeconds = 300;
    }
}
