package com.devdam.desktop.service;

import com.devdam.desktop.model.PackageConfiguration;
import com.devdam.desktop.model.PackagingResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

@Slf4j
@Service
public class PackagingService {
    
    public PackagingResult packageApplication(PackageConfiguration config, Consumer<String> logConsumer) {
        long startTime = System.currentTimeMillis();
        List<String> logs = new ArrayList<>();
        
        try {
            log.info("Starting packaging process for: {}", config.getAppName());
            
            // Validate configuration
            validateConfiguration(config);
            
            // Create output directory if it doesn't exist
            if (!Files.exists(config.getOutputDirectory())) {
                Files.createDirectories(config.getOutputDirectory());
                logs.add("Created output directory: " + config.getOutputDirectory());
            }
            
            // Step 1: Create custom runtime with jlink (if enabled)
            Path runtimePath = null;
            if (config.isEnableJLink()) {
                runtimePath = createCustomRuntime(config, logs, logConsumer);
            }
            
            // Step 2: Package application with jpackage
            boolean success = packageWithJPackage(config, runtimePath, logs, logConsumer);
            
            long executionTime = System.currentTimeMillis() - startTime;
            
            if (success) {
                String outputPath = config.getOutputDirectory().toString();
                return PackagingResult.success(
                    "Application packaged successfully!",
                    outputPath,
                    logs,
                    executionTime,
                    config
                );
            } else {
                return PackagingResult.failure(
                    "Packaging failed. Check logs for details.",
                    logs,
                    executionTime,
                    config
                );
            }
            
        } catch (Exception e) {
            log.error("Error during packaging", e);
            logs.add("ERROR: " + e.getMessage());
            long executionTime = System.currentTimeMillis() - startTime;
            
            return PackagingResult.failure(
                "Packaging failed: " + e.getMessage(),
                logs,
                executionTime,
                config
            );
        }
    }
    
    private void validateConfiguration(PackageConfiguration config) {
        if (config.getJarFile() == null || !Files.exists(config.getJarFile())) {
            throw new IllegalArgumentException("JAR file does not exist: " + config.getJarFile());
        }
        
        if (config.getAppName() == null || config.getAppName().trim().isEmpty()) {
            throw new IllegalArgumentException("Application name is required");
        }
        
        if (config.getMainClass() == null || config.getMainClass().trim().isEmpty()) {
            throw new IllegalArgumentException("Main class is required");
        }
        
        if (config.getOutputDirectory() == null) {
            throw new IllegalArgumentException("Output directory is required");
        }
    }
    
    private Path createCustomRuntime(PackageConfiguration config, List<String> logs, Consumer<String> logConsumer) 
            throws IOException, InterruptedException {
        
        logs.add("Creating custom runtime with jlink...");
        logConsumer.accept("Creating custom runtime with jlink...");
        
        Path runtimePath = config.getOutputDirectory().resolve("runtime");
        
        // Delete existing runtime directory
        if (Files.exists(runtimePath)) {
            deleteDirectory(runtimePath);
        }
        
        List<String> command = new ArrayList<>();
        command.add("jlink");
        command.add("--add-modules");
        command.add(String.join(",", config.getRequiredModules()));
        command.add("--output");
        command.add(runtimePath.toString());
        command.add("--compress=2");
        command.add("--no-header-files");
        command.add("--no-man-pages");
        
        ProcessBuilder pb = new ProcessBuilder(command);
        Process process = pb.start();
        
        // Read output
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
             BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                logs.add("jlink: " + line);
                logConsumer.accept("jlink: " + line);
            }
            
            while ((line = errorReader.readLine()) != null) {
                logs.add("jlink ERROR: " + line);
                logConsumer.accept("jlink ERROR: " + line);
            }
        }
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("jlink failed with exit code: " + exitCode);
        }
        
        logs.add("Custom runtime created successfully at: " + runtimePath);
        logConsumer.accept("Custom runtime created successfully");
        
        return runtimePath;
    }
    
    private boolean packageWithJPackage(PackageConfiguration config, Path runtimePath, 
                                      List<String> logs, Consumer<String> logConsumer) 
            throws IOException, InterruptedException {
        
        logs.add("Packaging application with jpackage...");
        logConsumer.accept("Packaging application with jpackage...");
        
        List<String> command = new ArrayList<>();
        command.add("jpackage");
        command.add("--input");
        command.add(config.getJarFile().getParent().toString());
        command.add("--main-jar");
        command.add(config.getJarFile().getFileName().toString());
        command.add("--main-class");
        command.add(config.getMainClass());
        command.add("--name");
        command.add(config.getAppName());
        command.add("--dest");
        command.add(config.getOutputDirectory().toString());
        
        // Add version if specified
        if (config.getVersion() != null && !config.getVersion().trim().isEmpty()) {
            command.add("--app-version");
            command.add(config.getVersion());
        }
        
        // Add icon if specified
        if (config.getIconFile() != null && Files.exists(config.getIconFile())) {
            command.add("--icon");
            command.add(config.getIconFile().toString());
        }
        
        // Add vendor if specified
        if (config.getVendor() != null && !config.getVendor().trim().isEmpty()) {
            command.add("--vendor");
            command.add(config.getVendor());
        }
        
        // Add description if specified
        if (config.getDescription() != null && !config.getDescription().trim().isEmpty()) {
            command.add("--description");
            command.add(config.getDescription());
        }
        
        // Add copyright if specified
        if (config.getCopyright() != null && !config.getCopyright().trim().isEmpty()) {
            command.add("--copyright");
            command.add(config.getCopyright());
        }
        
        // Add output format
        if (config.getOutputFormat() != null && config.getOutputFormat() != PackageConfiguration.OutputFormat.APP_IMAGE) {
            command.add("--type");
            command.add(config.getOutputFormat().getJPackageType());
        }
        
        // Add custom runtime if created
        if (runtimePath != null && Files.exists(runtimePath)) {
            command.add("--runtime-image");
            command.add(runtimePath.toString());
        }
        
        // Add JVM arguments if specified
        if (config.getJvmArgs() != null && !config.getJvmArgs().isEmpty()) {
            command.add("--java-options");
            command.add(String.join(" ", config.getJvmArgs()));
        }
        
        // Add application arguments if specified
        if (config.getAppArgs() != null && !config.getAppArgs().isEmpty()) {
            command.add("--arguments");
            command.add(String.join(" ", config.getAppArgs()));
        }
        
        ProcessBuilder pb = new ProcessBuilder(command);
        Process process = pb.start();
        
        // Read output
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
             BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                logs.add("jpackage: " + line);
                logConsumer.accept("jpackage: " + line);
            }
            
            while ((line = errorReader.readLine()) != null) {
                logs.add("jpackage ERROR: " + line);
                logConsumer.accept("jpackage ERROR: " + line);
            }
        }
        
        int exitCode = process.waitFor();
        if (exitCode == 0) {
            logs.add("Application packaged successfully!");
            logConsumer.accept("Application packaged successfully!");
            return true;
        } else {
            logs.add("jpackage failed with exit code: " + exitCode);
            logConsumer.accept("jpackage failed with exit code: " + exitCode);
            return false;
        }
    }
    
    private void deleteDirectory(Path directory) throws IOException {
        if (Files.exists(directory)) {
            Files.walk(directory)
                    .sorted((a, b) -> b.compareTo(a)) // Reverse order to delete files before directories
                    .forEach(path -> {
                        try {
                            Files.delete(path);
                        } catch (IOException e) {
                            log.warn("Could not delete: " + path, e);
                        }
                    });
        }
    }
    
    public boolean isJPackageAvailable() {
        try {
            ProcessBuilder pb = new ProcessBuilder("jpackage", "--version");
            Process process = pb.start();
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (Exception e) {
            log.warn("jpackage not available", e);
            return false;
        }
    }
    
    public boolean isJLinkAvailable() {
        try {
            ProcessBuilder pb = new ProcessBuilder("jlink", "--version");
            Process process = pb.start();
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (Exception e) {
            log.warn("jlink not available", e);
            return false;
        }
    }
}
