# 🧳 Packaroo

**From JAR to Anywhere — Pack it. Ship it. Done.**

**Packaroo** is a cross-platform **Java GUI application** that allows developers to easily convert their `.jar` files into native executables and installers using the Java packaging tools `jpackage` and `jlink`. Whether you're building for Windows, macOS, or Linux, Packaroo wraps your Java application into a clean, native, installable format — no manual scripting required.

---

## 🌟 Features

- ✅ Drag-and-drop `.jar` support
- 💻 Cross-platform native packaging with `jpackage`
- 🧱 Custom runtime generation with `jlink`
- 🖼️ App branding: name, icon, version, license info
- 🛠️ GUI configuration for app packaging options
- 🚀 Output formats: `.exe`, `.msi`, `.dmg`, `.pkg`, `.deb`, `.rpm`
- 📦 Optionally bundle your own JDK or generate minimal JREs
- 📋 Preset manager for repeatable builds

---

## 📸 Preview

> Coming soon — screenshots of the interface and packaging flow

---

## 🔧 Requirements

- **Java Development Kit (JDK) 14 or higher**
  - Must include `jpackage` and `jlink`
- Works on **Windows**, **macOS**, and **Linux**
- JavaFX (if using a JavaFX GUI)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/packaroo.git
cd packaroo
````

### 2. Build the Project

Using Maven:

```bash
mvn clean install
```

Or Gradle:

```bash
./gradlew build
```

### 3. Run Packaroo

```bash
java -jar target/packaroo.jar
```

---

## 💡 How It Works

1. Select your `.jar` file (your Java app)
2. Enter metadata like app name, version, icon, etc.
3. Choose whether to use a full JDK or generate a minimal runtime with `jlink`
4. Click **Build** — and Packaroo generates a native installer for your platform

---

## 📁 Project Structure

```
packaroo/
├── src/main/java/com/packaroo/
│   ├── Main.java               # Launches the GUI
│   ├── controllers/            # JavaFX controllers
│   ├── utils/                  # jpackage / jlink integration
├── src/main/resources/
│   ├── fxml/                   # JavaFX UI layout
│   ├── icons/                  # Default app icons
│   └── styles/                 # CSS themes
├── pom.xml                     # Maven build file
└── README.md
```

---

## 📦 Output Formats

| OS      | Format         |
| ------- | -------------- |
| Windows | `.exe`, `.msi` |
| macOS   | `.app`, `.pkg` |
| Linux   | `.deb`, `.rpm` |

> Platform-specific formats must be built **on that OS**.

---

## 🛠 Under the Hood

Packaroo wraps around official Java packaging tools:

* [`jpackage`](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jpackage.html)
* [`jlink`](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jlink.html)
* `jdeps` for dependency analysis (optional)

---

## 🧪 Roadmap

* [ ] GUI presets for common app types
* [ ] Icon/theme preview
* [ ] Build history and export logs
* [ ] Lightweight embedded JDK bundling
* [ ] Platform targeting via remote builders or Docker

---

## 🤝 Contributing

Pull requests are welcome! Please open an issue first to discuss major changes or feature ideas.

---

## 📄 License

Apache 2.0 License

---

## 💬 Questions?

Open an issue or contact us via [GitHub Discussions](https://github.com/yourusername/packaroo/discussions).

---

**Happy packing with Packaroo!** 🧳✨

