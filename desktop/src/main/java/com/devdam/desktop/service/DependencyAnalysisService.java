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
                return DependencyAnalysis.builder()
                        .success(false)
                        .jarPath(jarPath.toString())
                        .errorMessage("jdeps tool is not available. Please ensure JDK is properly installed.")
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
            return DependencyAnalysis.builder()
                    .success(false)
                    .jarPath(jarPath.toString())
                    .errorMessage("Failed to analyze dependencies: " + e.getMessage())
                    .build();
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
        
        ProcessBuilder pb = new ProcessBuilder("jdeps", "--print-module-deps", jarPath.toString());
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty()) {
                    // Split by comma and add each module
                    String[] moduleArray = line.split(",");
                    for (String module : moduleArray) {
                        modules.add(module.trim());
                    }
                }
            }
        }
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("jdeps failed with exit code: " + exitCode);
        }
        
        return modules;
    }
    
    private Set<String> getAvailableModules() throws IOException, InterruptedException {
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
        // Common modules that are often needed
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
                "jdk.crypto.ec",
                "jdk.localedata",
                "jdk.unsupported"
        );
    }
}
