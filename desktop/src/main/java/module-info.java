// Temporarily comment out module-info.java for Spring Boot compatibility
// Spring Boot fat JARs work better without module system in jpackage
/*
module com.devdam.desktop {
    // JavaFX modules
    requires javafx.controls;
    requires javafx.fxml;
    requires javafx.graphics;
    requires javafx.base;
    requires static javafx.web; // Make web module optional
    
    // Spring Boot modules
    requires spring.boot;
    requires spring.boot.autoconfigure;
    requires spring.context;
    requires spring.core;
    requires spring.beans;
    
    // Other required modules
    requires java.desktop;
    requires java.logging;
    requires java.prefs;
    requires org.controlsfx.controls;
    requires com.fasterxml.jackson.databind;
    requires com.fasterxml.jackson.datatype.jsr310;
    requires static lombok;
    requires org.slf4j;
    
    // Open packages for Spring reflection and FXML loading
    opens com.devdam.desktop to spring.core, spring.beans, spring.context, javafx.fxml;
    opens com.devdam.desktop.service to spring.core, spring.beans, spring.context, javafx.fxml;
    opens com.devdam.desktop.controller to spring.core, spring.beans, spring.context, javafx.fxml;
    opens com.devdam.desktop.model to spring.core, spring.beans, spring.context, javafx.fxml, com.fasterxml.jackson.databind;
    
    // Export main package
    exports com.devdam.desktop;
}
*/
