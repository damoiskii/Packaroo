package com.devdam.desktop.model;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DependencyAnalysis {
    
    private boolean success;
    private String jarPath;
    private Set<String> requiredModules;
    private Set<String> availableModules;
    private Set<String> missingModules;
    private String mainClass;
    private String errorMessage;
    
    public boolean hasRequiredModules() {
        return requiredModules != null && !requiredModules.isEmpty();
    }
    
    public boolean hasMissingModules() {
        return missingModules != null && !missingModules.isEmpty();
    }
}
