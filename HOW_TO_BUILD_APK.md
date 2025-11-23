# 🏗️ How to Build APK File

**Quick answer**: There are 3 ways to build the APK for this Flutter app. Choose the one that fits your needs:

---

## ⚡ Method 1: GitHub Actions (EASIEST - No Setup Required)

**Best for**: Getting an APK without installing anything

### Steps:
1. Go to your repository on GitHub
2. Click the **"Actions"** tab at the top
3. Click **"Build Flutter APK"** workflow on the left
4. Click **"Run workflow"** button (top right)
5. Click **"Run workflow"** in the dropdown
6. Wait 3-5 minutes for the build to complete ⏱️
7. Once done, scroll down to **"Artifacts"** section
8. Look for an artifact with your app name (e.g., "myflutter-release-apk" or "app-release")
9. Click to download the artifact
10. Extract the ZIP file
11. You'll find the APK file inside ✅

**Install on Android**:
- Transfer APK to your phone
- Open it and tap "Install"
- (You may need to enable "Install from unknown sources" in Settings)

---

## ☁️ Method 2: GitHub Codespaces (No Local Setup)

**Best for**: Developing and building in the cloud

### Steps:
1. Click the **"Code"** button (green) in your repository
2. Switch to **"Codespaces"** tab
3. Click **"Create codespace on main"**
4. Wait for the environment to initialize (2-3 minutes) ⏱️
5. Once ready, open the terminal and run:

```bash
flutter pub get
flutter build apk --release
```

6. The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
7. Right-click the file → **"Download"** ✅

---

## 💻 Method 3: Build Locally

**Best for**: Local development with full control

### Prerequisites:
- Flutter SDK (latest stable version recommended)
- Android Studio (or Android SDK)
- Java 17 or later

### Steps:

```bash
# 1. Clone the repository (if not done already)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 2. Install dependencies
flutter pub get

# 3. Build the APK
flutter build apk --release

# 4. Find your APK here:
# build/app/outputs/flutter-apk/app-release.apk
```

**Verify Flutter is installed**:
```bash
flutter doctor
```
If this shows issues, fix them before building.

---

## 📦 Build Variants

You can build different types of APKs:

```bash
# Release APK (smallest, optimized - recommended)
flutter build apk --release

# Debug APK (larger, with debugging info)
flutter build apk --debug

# Split APKs by architecture (multiple smaller files)
flutter build apk --split-per-abi
```

---

## 🎯 APK Location

After building, your APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

The file size is approximately **17-20 MB** for release builds.

---

## ❓ Troubleshooting

### Build fails?
- Run `flutter doctor` to check your setup
- Run `flutter clean` then try again
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed help

### Can't find the APK?
- Check the exact path: `build/app/outputs/flutter-apk/`
- Make sure the build completed successfully (no errors in terminal)

### APK won't install?
- Enable "Install from unknown sources" on your Android device
- Make sure your Android version is 5.0 or higher
- Try uninstalling any previous version first

---

## 📚 More Information

- **Detailed Building Guide**: [BUILDING.md](BUILDING.md)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)
- **Main README**: [README.md](README.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🚀 Summary

**Quickest**: Use GitHub Actions (Method 1) - no setup needed, just click and download

**Most Flexible**: Build locally (Method 3) - requires Flutter setup but gives you full control

**Good Middle Ground**: Use Codespaces (Method 2) - cloud environment with Flutter pre-installed
