package com.monitor.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class SystemMemoryInfoDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long totalMemoryBytes;

    private Double totalMemoryGb;

    private Long availableMemoryBytes;

    private Double availableMemoryGb;

    private Long usedMemoryBytes;

    private Double usedMemoryGb;

    private Double usedPercent;

    private Integer processCount;

    private Integer alertProcessCount;

    private Double alertThresholdPercent;
}
