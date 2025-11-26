# Troubleshooting Guide

Common issues and their solutions when building MyFlutter app.

## 🔧 GitHub Actions Issues

### Build Failed - "Flutter not found"

**Symptom**: Workflow fails with "flutter: command not found"

**Solution**: 
- Check that `flutter-action@v2` is properly configured in workflow file
- Verify Flutter version is valid (currently set to 3.24.3)
- Try re-running the workflow

### Build Failed - "Gradle build failed"

**Symptom**: Build fails during APK generation step

**Solution**:
- Check if `build.gradle` files are properly committed
- Verify Android SDK versions in `android/app/build.gradle` are valid
- Check workflow logs for specific Gradle error messages
- Ensure `gradle-wrapper.jar` is committed (not in .gitignore)

### Can't Find APK Artifact

**Symptom**: No artifacts appear after successful build

**Solution**:
- Ensure workflow completed successfully (green checkmark)
- Wait for artifact upload step to complete
- Check if `actions/upload-artifact@v4` step succeeded
- Artifacts expire after retention period (90 days for this project)

---

## 🌐 GitHub Codespaces Issues

### Codespace Won't Start

**Symptom**: Codespace creation fails or times out

**Solution**:
- Check GitHub status page for Codespaces outages
- Try creating codespace again
- Verify your GitHub account has Codespaces access
- Check if devcontainer.json syntax is valid

### Flutter Commands Not Working

**Symptom**: `flutter: command not found` in Codespace terminal

**Solution**:
```bash
# Check if Flutter is in PATH
echo $PATH | grep flutter

# If not, add Flutter to PATH temporarily
export PATH="/sdks/flutter/bin:$PATH"

# Verify Flutter is working
flutter --version

# If still not working, reinstall Flutter in codespace
git clone https://github.com/flutter/flutter.git -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"
```

### PostCreateCommand Failed

**Symptom**: Codespace starts but initialization fails

**Solution**:
- Check `.devcontainer/devcontainer.json` syntax
- Manually run: `flutter doctor && flutter pub get`
- Check if internet connectivity is working
- Review codespace creation logs

---

## 💻 Local Development Issues

### Flutter Doctor Issues

#### Android licenses not accepted

**Symptom**: `flutter doctor` shows red X for Android licenses

**Solution**:
```bash
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

#### Android SDK not found

**Symptom**: `flutter doctor` reports missing Android SDK

**Solution**:
- Install Android Studio
- Open Android Studio → Settings → Android SDK
- Install required SDK versions (API 34 recommended)
- Set ANDROID_HOME environment variable:
  ```bash
  # Linux/Mac
  export ANDROID_HOME=$HOME/Android/Sdk
  export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
  
  # Windows (in System Environment Variables)
  ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
  ```

#### Java version issues

**Symptom**: Build fails with Java version error

**Solution**:
- Install Java 17 (JDK 17)
- Set JAVA_HOME:
  ```bash
  # Linux/Mac
  export JAVA_HOME=/path/to/jdk-17
  
  # Windows
  set JAVA_HOME=C:\Program Files\Java\jdk-17
  ```
- Verify: `java -version`

### Gradle Build Issues

#### Gradle daemon timeout

**Symptom**: "Gradle build daemon disappeared unexpectedly"

**Solution**:
```bash
# Increase Gradle memory
export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=2048m"

# Or edit gradle.properties
echo "org.gradle.jvmargs=-Xmx4096m" >> android/gradle.properties

# Clear Gradle cache
cd android
./gradlew clean
cd ..
```

#### Dependencies download failed

**Symptom**: "Could not resolve all dependencies"

**Solution**:
```bash
# Clear Flutter cache
flutter pub cache repair

# Clear Gradle cache
cd android
./gradlew clean --refresh-dependencies
cd ..

# Try build again
flutter pub get
flutter build apk
```

### APK Build Issues

#### Build fails at signing

**Symptom**: "Execution failed for task ':app:packageRelease'"

**Solution**:
- For debug builds, use: `flutter build apk --debug`
- For release with debug signing: `flutter build apk --release` (already configured)
- To create your own keystore for production:
  ```bash
  keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
  ```

#### Out of memory during build

**Symptom**: "OutOfMemoryError: Java heap space"

**Solution**:
```bash
# Edit android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=2048m

# Or increase system-wide
export _JAVA_OPTIONS="-Xmx4096m"
```

---

## 📱 Device/Emulator Issues

### No Devices Found

**Symptom**: `flutter devices` shows no devices

**Solution**:

For **Emulator**:
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Or launch from Android Studio
```

For **Physical Device**:
1. Enable Developer Options:
   - Settings → About Phone → Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging
3. Connect via USB
4. Accept "Allow USB debugging" on device
5. Verify: `flutter devices`

### App Won't Install on Device

**Symptom**: APK transfer works but installation fails

**Solution**:
1. Enable "Install from unknown sources":
   - Settings → Security → Unknown Sources (or "Install unknown apps")
2. Check if app is already installed:
   - Uninstall old version first
3. Verify APK is not corrupted:
   - Try transferring again
4. Check Android version compatibility:
   - Min SDK is 21 (Android 5.0)

### App Update Fails - "App not installed" or "Signature mismatch"

**Symptom**: Cannot update installed app, need to uninstall first

**Root Cause**: The new APK is signed with a different keystore than the installed version.

**Solution**:
1. **For developers**: Set up a release keystore to ensure consistent signing
   - See [KEYSTORE_SETUP.md](KEYSTORE_SETUP.md) for detailed instructions
   - Once configured, all future builds will use the same signature
2. **For current users**: One-time uninstall required
   - Uninstall the old version
   - Install the new properly-signed version
   - Future updates will work seamlessly
3. **Quick setup**:
   ```bash
   # Generate keystore (do this once)
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   
   # Create key.properties in android/ directory
   cat > android/key.properties << EOF
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=/path/to/upload-keystore.jks
   EOF
   
   # Build with release signing
   flutter build apk --release
   ```

**Prevention**: Always use the same keystore for all releases. Back up your keystore securely!

---

## 🔍 Dependency Issues

### Package Version Conflicts

**Symptom**: `pub get` fails with version conflict errors

**Solution**:
```bash
# Delete pubspec.lock
rm pubspec.lock

# Clear pub cache
flutter pub cache repair

# Get dependencies again
flutter pub get

# If still fails, update all packages
flutter pub upgrade
```

### Flutter SDK Version Mismatch

**Symptom**: "The current Flutter SDK version is x.x.x but this requires >=y.y.y"

**Solution**:
```bash
# Update Flutter to latest stable
flutter upgrade

# Or switch to specific version
flutter version 3.24.3

# Verify version
flutter --version
```

---

## 🧪 Testing Issues

### Tests Fail

**Symptom**: `flutter test` shows failed tests

**Solution**:
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test file
flutter test test/widget_test.dart

# Update golden files if UI tests fail
flutter test --update-goldens
```

### Test Timeout

**Symptom**: Tests hang or timeout

**Solution**:
```bash
# Increase timeout
flutter test --timeout=5m

# Run tests without animations
flutter test --no-enable-experiments
```

---

## 📊 Performance Issues

### Slow Build Times

**Solution**:
```bash
# Enable Gradle daemon
echo "org.gradle.daemon=true" >> android/gradle.properties

# Enable parallel builds
echo "org.gradle.parallel=true" >> android/gradle.properties

# Use build cache
echo "org.gradle.caching=true" >> android/gradle.properties
```

### Large APK Size

**Solution**:
```bash
# Build split APKs per architecture
flutter build apk --split-per-abi

# Enable code shrinking
# Add to android/app/build.gradle:
buildTypes {
    release {
        shrinkResources true
        minifyEnabled true
    }
}
```

---

## 🆘 Still Having Issues?

1. **Check Flutter Doctor**: `flutter doctor -v` for detailed diagnostics
2. **Clean and Rebuild**: 
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```
3. **Check Logs**: Look at detailed error messages in terminal
4. **Update Flutter**: `flutter upgrade` to get latest fixes
5. **Search Issues**: Check [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
6. **Ask for Help**: Post on [Flutter Discord](https://discord.gg/flutter) or [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## 📝 Getting Help

When asking for help, include:
- Flutter version: `flutter --version`
- Doctor output: `flutter doctor -v`
- Error message (full text)
- Steps to reproduce
- Operating system and version
- What you've already tried

---

## 🔗 Useful Commands

```bash
# Complete cleanup and rebuild
flutter clean && flutter pub get && flutter build apk

# Check for issues
flutter doctor -v

# Update everything
flutter upgrade && flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Check dependencies
flutter pub outdated
```
