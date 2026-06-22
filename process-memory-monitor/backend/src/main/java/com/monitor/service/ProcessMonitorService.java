package com.monitor.service;

import com.monitor.dto.ProcessInfoDTO;
import com.monitor.dto.SystemMemoryInfoDTO;

import java.util.List;

public interface ProcessMonitorService {

    List<ProcessInfoDTO> getAllProcesses();

    SystemMemoryInfoDTO getSystemMemoryInfo();

    List<ProcessInfoDTO> getAlertProcesses();
}
