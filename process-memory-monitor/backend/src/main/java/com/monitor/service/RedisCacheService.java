package com.monitor.service;

import com.monitor.dto.ProcessInfoDTO;
import com.monitor.dto.SystemMemoryInfoDTO;

import java.util.List;

public interface RedisCacheService {

    void cacheProcessList(List<ProcessInfoDTO> processList);

    List<ProcessInfoDTO> getCachedProcessList();

    void cacheSystemMemoryInfo(SystemMemoryInfoDTO memoryInfo);

    SystemMemoryInfoDTO getCachedSystemMemoryInfo();

    void cacheAlertProcesses(List<ProcessInfoDTO> alertProcesses);

    List<ProcessInfoDTO> getCachedAlertProcesses();
}
