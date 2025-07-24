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
    private String startClass;  // Spring Boot Start-Class (actual application class)
    private String errorMessage;
    
    // Manifest/JAR metadata
    private String implementationTitle;
    private String implementationVersion;
    private String implementationVendor;
    private String specificationTitle;
    private String specificationVersion;
    private String specificationVendor;
    private String bundleName;
    private String bundleVersion;
    private String bundleVendor;
    private String bundleDescription;
    
    public boolean hasRequiredModules() {
        return requiredModules != null && !requiredModules.isEmpty();
    }
    
    public boolean hasMissingModules() {
        return missingModules != null && !missingModules.isEmpty();
    }
    
    public boolean hasManifestInfo() {
        return implementationTitle != null || implementationVersion != null || 
               implementationVendor != null || specificationTitle != null;
    }
}
