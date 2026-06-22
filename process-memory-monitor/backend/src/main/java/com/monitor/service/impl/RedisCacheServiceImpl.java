package com.monitor.service.impl;

import com.alibaba.fastjson.JSON;
import com.monitor.config.MonitorConfig;
import com.monitor.dto.ProcessInfoDTO;
import com.monitor.dto.SystemMemoryInfoDTO;
import com.monitor.service.RedisCacheService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@ConditionalOnProperty(prefix = "monitor.redis", name = "enabled", havingValue = "true")
public class RedisCacheServiceImpl implements RedisCacheService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private MonitorConfig monitorConfig;

    private static final String PROCESS_LIST_KEY = "process_list";
    private static final String SYSTEM_MEMORY_KEY = "system_memory";
    private static final String ALERT_PROCESSES_KEY = "alert_processes";

    @Override
    public void cacheProcessList(List<ProcessInfoDTO> processList) {
        try {
            String key = buildKey(PROCESS_LIST_KEY);
            String value = JSON.toJSONString(processList);
            redisTemplate.opsForValue().set(key, value,
                    monitorConfig.getRedis().getExpireSeconds(), TimeUnit.SECONDS);
            log.debug("缓存进程列表成功，共 {} 个进程", processList.size());
        } catch (Exception e) {
            log.warn("缓存进程列表失败: {}", e.getMessage());
        }
    }

    @Override
    public List<ProcessInfoDTO> getCachedProcessList() {
        try {
            String key = buildKey(PROCESS_LIST_KEY);
            String value = redisTemplate.opsForValue().get(key);
            if (value != null) {
                return JSON.parseArray(value, ProcessInfoDTO.class);
            }
        } catch (Exception e) {
            log.warn("获取缓存进程列表失败: {}", e.getMessage());
        }
        return Collections.emptyList();
    }

    @Override
    public void cacheSystemMemoryInfo(SystemMemoryInfoDTO memoryInfo) {
        try {
            String key = buildKey(SYSTEM_MEMORY_KEY);
            String value = JSON.toJSONString(memoryInfo);
            redisTemplate.opsForValue().set(key, value,
                    monitorConfig.getRedis().getExpireSeconds(), TimeUnit.SECONDS);
            log.debug("缓存系统内存信息成功");
        } catch (Exception e) {
            log.warn("缓存系统内存信息失败: {}", e.getMessage());
        }
    }

    @Override
    public SystemMemoryInfoDTO getCachedSystemMemoryInfo() {
        try {
            String key = buildKey(SYSTEM_MEMORY_KEY);
            String value = redisTemplate.opsForValue().get(key);
            if (value != null) {
                return JSON.parseObject(value, SystemMemoryInfoDTO.class);
            }
        } catch (Exception e) {
            log.warn("获取缓存系统内存信息失败: {}", e.getMessage());
        }
        return null;
    }

    @Override
    public void cacheAlertProcesses(List<ProcessInfoDTO> alertProcesses) {
        try {
            String key = buildKey(ALERT_PROCESSES_KEY);
            String value = JSON.toJSONString(alertProcesses);
            redisTemplate.opsForValue().set(key, value,
                    monitorConfig.getRedis().getExpireSeconds(), TimeUnit.SECONDS);
            log.debug("缓存告警进程列表成功，共 {} 个", alertProcesses.size());
        } catch (Exception e) {
            log.warn("缓存告警进程列表失败: {}", e.getMessage());
        }
    }

    @Override
    public List<ProcessInfoDTO> getCachedAlertProcesses() {
        try {
            String key = buildKey(ALERT_PROCESSES_KEY);
            String value = redisTemplate.opsForValue().get(key);
            if (value != null) {
                return JSON.parseArray(value, ProcessInfoDTO.class);
            }
        } catch (Exception e) {
            log.warn("获取缓存告警进程列表失败: {}", e.getMessage());
        }
        return Collections.emptyList();
    }

    private String buildKey(String key) {
        return monitorConfig.getRedis().getKeyPrefix() + key;
    }
}
