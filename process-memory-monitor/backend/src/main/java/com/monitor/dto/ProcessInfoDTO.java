package com.monitor.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class ProcessInfoDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer processId;

    private String processName;

    private Long memoryUsageBytes;

    private Double memoryUsageMb;

    private Double memoryPercent;

    private Boolean isAlert;

    private String alertMessage;
}
