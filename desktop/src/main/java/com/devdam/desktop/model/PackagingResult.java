package com.devdam.desktop.model;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PackagingResult {
    
    private boolean success;
    private String message;
    private LocalDateTime timestamp;
    private List<String> logs;
    private String outputPath;
    private long executionTimeMs;
    private PackageConfiguration configuration;
    
    public static PackagingResult success(String message, String outputPath, 
                                        List<String> logs, long executionTimeMs, 
                                        PackageConfiguration config) {
        return PackagingResult.builder()
                .success(true)
                .message(message)
                .outputPath(outputPath)
                .logs(logs)
                .executionTimeMs(executionTimeMs)
                .configuration(config)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    public static PackagingResult failure(String message, List<String> logs, 
                                        long executionTimeMs, PackageConfiguration config) {
        return PackagingResult.builder()
                .success(false)
                .message(message)
                .logs(logs)
                .executionTimeMs(executionTimeMs)
                .configuration(config)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
