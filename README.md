# MyFlutter

A Flutter Android application that can be built using GitHub Codespaces and GitHub Actions.

## 🎯 **[→ How to Build APK File](HOW_TO_BUILD_APK.md)** ← Start Here!

## 📖 Documentation

- **[How to Build APK](HOW_TO_BUILD_APK.md)** - **Start here!** Simple guide to build your APK
- **[Quick Start Guide](QUICKSTART.md)** - Get started in 5 minutes
- **[Detailed Building Instructions](BUILDING.md)** - Complete build guide
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Fix common issues
- **[GitHub Actions Workflows](.github/workflows/README.md)** - CI/CD documentation

## 📱 Features

- Simple counter app built with Flutter
- Material Design 3
- Automated builds via GitHub Actions
- Development environment ready in GitHub Codespaces

## 🚀 Quick Start

### Option 1: Build with GitHub Actions (Recommended)

1. Push code to GitHub or trigger workflow manually
2. Go to **Actions** tab in your repository
3. Click on the latest workflow run
4. Download the APK from **Artifacts** section
5. Install APK on your Android device

### Option 2: Build in GitHub Codespaces

1. Click the **Code** button in GitHub
2. Select **Codespaces** tab
3. Click **Create codespace on main**
4. Wait for the environment to initialize
5. Run the following commands in the terminal:

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# APK will be in: build/app/outputs/flutter-apk/app-release.apk
```

### Option 3: Build Locally

#### Prerequisites
- Flutter SDK (3.24.3 or later)
- Android Studio or Android SDK
- Java 17 or later

#### Steps
```bash
# Clone repository
git clone https://github.com/apkarthik1986/MyFlutter.git
cd MyFlutter

# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 📦 APK Download

After each successful build, the APK is automatically uploaded as an artifact in GitHub Actions. You can download it from:

1. Go to **Actions** tab
2. Click on the latest successful workflow run
3. Scroll down to **Artifacts**
4. Download `myflutter-release-apk`

Artifacts are retained for 90 days.

## 🛠️ Development

### Run in Debug Mode
```bash
flutter run
```

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

## 📂 Project Structure

```
MyFlutter/
├── .devcontainer/          # GitHub Codespaces configuration
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── android/                # Android-specific files
├── lib/
│   └── main.dart          # Main Flutter application
├── test/                   # Test files
├── pubspec.yaml           # Flutter dependencies
└── README.md              # This file
```

## 🔧 Configuration

- **Flutter Version**: 3.24.3
- **Dart SDK**: >=3.2.0 <4.0.0
- **Min Android SDK**: 21 (Android 5.0)
- **Target Android SDK**: 34 (Android 14)

## 📝 License

This is a sample Flutter application for demonstration purposes.