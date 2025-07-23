package com.devdam.desktop.service;

import com.devdam.desktop.model.DependencyAnalysis;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
public class DependencyAnalysisService {
    
    public DependencyAnalysis analyzeJar(Path jarPath) {
        log.info("Analyzing dependencies for JAR: {}", jarPath);
        
        try {
            // Check if jdeps is available
            if (!isJdepsAvailable()) {
                log.warn("jdeps is not available, using default module set");
                // Return success with default modules instead of failing
                Set<String> defaultModules = getDefaultJavaFXModules();
                Set<String> availableModules = getAvailableModules();
                
                return DependencyAnalysis.builder()
                        .success(true)
                        .jarPath(jarPath.toString())
                        .requiredModules(defaultModules)
                        .availableModules(availableModules)
                        .missingModules(new HashSet<>())
                        .mainClass(detectMainClass(jarPath))
                        .errorMessage("jdeps not available - using default JavaFX modules")
                        .build();
            }
            
            // Run jdeps to get module dependencies
            Set<String> requiredModules = getRequiredModules(jarPath);
            Set<String> availableModules = getAvailableModules();
            Set<String> missingModules = findMissingModules(requiredModules, availableModules);
            String mainClass = detectMainClass(jarPath);
            
            return DependencyAnalysis.builder()
                    .success(true)
                    .jarPath(jarPath.toString())
                    .requiredModules(requiredModules)
                    .availableModules(availableModules)
                    .missingModules(missingModules)
                    .mainClass(mainClass)
                    .build();
                    
        } catch (Exception e) {
            log.error("Failed to analyze JAR dependencies", e);
            // Return success with default modules instead of failing completely
            Set<String> defaultModules = getDefaultJavaFXModules();
            Set<String> availableModules = getAvailableModules();
            
            return DependencyAnalysis.builder()
                    .success(true)
                    .jarPath(jarPath.toString())
                    .requiredModules(defaultModules)
                    .availableModules(availableModules)
                    .missingModules(new HashSet<>())
                    .mainClass(detectMainClass(jarPath))
                    .errorMessage("Analysis failed, using default modules: " + e.getMessage())
                    .build();
        }
    }
    
    private Set<String> getAvailableModules() {
        try {
            return getAvailableModulesInternal();
        } catch (Exception e) {
            log.warn("Could not get available modules", e);
            return new HashSet<>();
        }
    }
    
    private boolean isJdepsAvailable() {
        try {
            ProcessBuilder pb = new ProcessBuilder("jdeps", "--version");
            Process process = pb.start();
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (Exception e) {
            log.warn("jdeps not available", e);
            return false;
        }
    }
    
    private Set<String> getRequiredModules(Path jarPath) throws IOException, InterruptedException {
        Set<String> modules = new HashSet<>();
        
        // First try with --ignore-missing-deps for Spring Boot fat JARs
        ProcessBuilder pb = new ProcessBuilder("jdeps", "--print-module-deps", "--ignore-missing-deps", jarPath.toString());
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
             BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty() && !line.startsWith("Error:") && !line.contains("not found")) {
                    // Split by comma and add each module
                    String[] moduleArray = line.split(",");
                    for (String module : moduleArray) {
                        String cleanModule = module.trim();
                        // Filter out problematic modules that might not be available
                        if (isModuleAvailable(cleanModule)) {
                            modules.add(cleanModule);
                        } else {
                            log.debug("Skipping unavailable module: {}", cleanModule);
                        }
                    }
                }
            }
            
            // Log error output for debugging but don't fail
            while ((line = errorReader.readLine()) != null) {
                log.debug("jdeps stderr: {}", line);
            }
        }
        
        int exitCode = process.waitFor();
        
        // If jdeps failed, fall back to default JavaFX modules
        if (exitCode != 0 || modules.isEmpty()) {
            log.warn("jdeps analysis failed or returned no modules, using default JavaFX modules");
            modules = getDefaultJavaFXModules();
        }
        
        // Ensure essential JavaFX modules are included if this is a JavaFX application
        if (isJavaFXApplication(jarPath)) {
            addEssentialJavaFXModules(modules);
        }
        
        return modules;
    }
    
    private Set<String> getDefaultJavaFXModules() {
        Set<String> modules = new HashSet<>();
        String[] defaultModules = {
            "java.base",
            "java.desktop", 
            "java.logging",
            "java.management",
            "java.naming",
            "java.prefs",
            "java.xml",
            "javafx.controls",
            "javafx.fxml",
            "javafx.base",
            "javafx.graphics"
        };
        
        for (String module : defaultModules) {
            if (isModuleAvailable(module)) {
                modules.add(module);
                log.debug("Added default module: {}", module);
            }
        }
        
        return modules;
    }
    
    private boolean isModuleAvailable(String moduleName) {
        try {
            // Get list of available modules
            Set<String> availableModules = getAvailableModules();
            boolean available = availableModules.contains(moduleName);
            
            // Special handling for known problematic modules
            if (!available && isProblematicModule(moduleName)) {
                log.info("Module {} is not available in current runtime, skipping", moduleName);
                return false;
            }
            
            return available;
        } catch (Exception e) {
            log.warn("Could not check availability of module: {}", moduleName, e);
            return false;
        }
    }
    
    private boolean isProblematicModule(String moduleName) {
        // List of modules that are often problematic or not available in all distributions
        return moduleName.equals("jdk.management.jfr") ||
               moduleName.equals("jdk.jfr") ||
               moduleName.equals("jdk.management.agent") ||
               moduleName.startsWith("jdk.internal.") ||
               moduleName.contains("incubator");
    }
    
    private boolean isJavaFXApplication(Path jarPath) {
        try {
            ProcessBuilder pb = new ProcessBuilder("jar", "-tf", jarPath.toString());
            Process process = pb.start();
            
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.contains("javafx") || line.contains("JavaFX")) {
                        return true;
                    }
                }
            }
            process.waitFor();
        } catch (Exception e) {
            log.debug("Could not check if JAR is JavaFX application", e);
        }
        return false;
    }
    
    private void addEssentialJavaFXModules(Set<String> modules) {
        // Add essential JavaFX modules that might not be detected by jdeps
        String[] essentialJavaFXModules = {
            "javafx.controls",
            "javafx.fxml",
            "javafx.base",
            "javafx.graphics"
        };
        
        for (String module : essentialJavaFXModules) {
            if (isModuleAvailable(module)) {
                modules.add(module);
                log.debug("Added essential JavaFX module: {}", module);
            }
        }
    }
    
    private Set<String> getAvailableModulesInternal() throws IOException, InterruptedException {
        Set<String> modules = new HashSet<>();
        
        ProcessBuilder pb = new ProcessBuilder("java", "--list-modules");
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty() && line.contains("@")) {
                    // Extract module name (before @)
                    String moduleName = line.split("@")[0];
                    modules.add(moduleName);
                }
            }
        }
        
        process.waitFor();
        return modules;
    }
    
    private Set<String> findMissingModules(Set<String> required, Set<String> available) {
        Set<String> missing = new HashSet<>(required);
        missing.removeAll(available);
        return missing;
    }
    
    private String detectMainClass(Path jarPath) {
        try {
            // Try to extract Main-Class from JAR manifest
            ProcessBuilder pb = new ProcessBuilder("jar", "-tf", jarPath.toString());
            Process process = pb.start();
            
            // Look for META-INF/MANIFEST.MF
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.equals("META-INF/MANIFEST.MF")) {
                        return extractMainClassFromManifest(jarPath);
                    }
                }
            }
            
            process.waitFor();
        } catch (Exception e) {
            log.warn("Could not detect main class from JAR manifest", e);
        }
        
        return null;
    }
    
    private String extractMainClassFromManifest(Path jarPath) {
        try {
            ProcessBuilder pb = new ProcessBuilder("jar", "-xf", jarPath.toString(), "META-INF/MANIFEST.MF");
            pb.directory(jarPath.getParent().toFile());
            Process process = pb.start();
            process.waitFor();
            
            // Read the manifest file
            Path manifestPath = jarPath.getParent().resolve("META-INF/MANIFEST.MF");
            if (manifestPath.toFile().exists()) {
                List<String> lines = java.nio.file.Files.readAllLines(manifestPath);
                for (String line : lines) {
                    if (line.startsWith("Main-Class:")) {
                        return line.substring("Main-Class:".length()).trim();
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Could not extract main class from manifest", e);
        }
        
        return null;
    }
    
    public List<String> getSuggestedModules() {
        // Common modules that are often needed, focusing on safe, widely available modules
        return List.of(
                "java.base",
                "java.desktop",
                "java.logging",
                "java.management",
                "java.naming",
                "java.prefs",
                "java.security.jgss",
                "java.sql",
                "java.xml",
                "javafx.controls",
                "javafx.fxml",
                "javafx.base",
                "javafx.graphics",
                "jdk.crypto.ec",
                "jdk.localedata",
                "jdk.unsupported"
        );
    }
}
