package com.devdam.desktop.model;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.nio.file.Path;
import java.util.List;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PackageConfiguration {
    
    // Basic configuration
    private Path jarFile;
    private String appName;
    private String version;
    private String mainClass;
    private Path iconFile;
    private Path outputDirectory;
    
    // Platform and format
    private TargetPlatform targetPlatform;
    private OutputFormat outputFormat;
    
    // JLink configuration
    private boolean enableJLink;
    private Set<String> requiredModules;
    
    // Additional options
    private String vendor;
    private String description;
    private String copyright;
    private List<String> jvmArgs;
    private List<String> appArgs;
    
    public enum TargetPlatform {
        WINDOWS("Windows"),
        MACOS("macOS"),
        LINUX("Linux"),
        CURRENT("Current Platform");
        
        private final String displayName;
        
        TargetPlatform(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    public enum OutputFormat {
        APP_IMAGE("App Image"),
        EXE("Windows Executable (.exe)"),
        MSI("Windows Installer (.msi)"),
        PKG("macOS Package (.pkg)"),
        DMG("macOS Disk Image (.dmg)"),
        DEB("Debian Package (.deb)"),
        RPM("Red Hat Package (.rpm)");
        
        private final String displayName;
        
        OutputFormat(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
        
        public String getJPackageType() {
            return switch (this) {
                case APP_IMAGE -> "app-image";
                case EXE -> "exe";
                case MSI -> "msi";
                case PKG -> "pkg";
                case DMG -> "dmg";
                case DEB -> "deb";
                case RPM -> "rpm";
            };
        }
    }
}
