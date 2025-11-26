# Keystore Setup Guide

This guide explains how to set up a release keystore to enable seamless app updates without requiring users to uninstall.

## Why Keystore is Important

Android apps must be signed with the same digital signature (keystore) for updates to work. If you try to update an app signed with a different keystore, Android will reject the update and require users to uninstall the old version first.

## Problem Fixed

**Before**: Using debug signing meant each build environment had a different signature, requiring users to uninstall and reinstall.

**After**: Using a consistent release keystore allows users to update the app normally without uninstalling.

## Setup Instructions

### Step 1: Generate a Release Keystore

Run this command to create a new keystore (only do this once):

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype JKS
```

You'll be prompted to enter:
- **Keystore password**: Choose a strong password (remember this!)
- **Key password**: Choose a strong password (remember this!)
- **Your name, organization, etc.**: Fill in your details

**Important**: Keep your keystore file and passwords safe! Store them securely. If you lose them, you won't be able to update your app.

### Step 2: Create key.properties File

Create a file named `key.properties` in the `android/` directory with this content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/your/upload-keystore.jks
```

Replace:
- `YOUR_KEYSTORE_PASSWORD` with your keystore password
- `YOUR_KEY_PASSWORD` with your key password
- `/path/to/your/upload-keystore.jks` with the actual path to your keystore file

**Example for Linux/Mac**:
```properties
storePassword=mySecurePassword123
keyPassword=mySecurePassword123
keyAlias=upload
storeFile=/home/username/upload-keystore.jks
```

**Example for Windows**:
```properties
storePassword=mySecurePassword123
keyPassword=mySecurePassword123
keyAlias=upload
storeFile=C:/Users/username/upload-keystore.jks
```

### Step 3: Verify the Setup

Build your release APK to verify everything works:

```bash
flutter build apk --release
```

If successful, your APK will be signed with your release keystore and can be found at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Actions Setup

For GitHub Actions to build signed APKs, you need to:

### 1. Encode Your Keystore to Base64

```bash
base64 -i upload-keystore.jks -o keystore-base64.txt
# On some systems, use:
base64 upload-keystore.jks > keystore-base64.txt
```

### 2. Add GitHub Secrets

Go to your repository on GitHub:
1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `KEYSTORE_BASE64` | Contents of `keystore-base64.txt` |
| `KEYSTORE_PASSWORD` | Your keystore password |
| `KEY_PASSWORD` | Your key password |
| `KEY_ALIAS` | `upload` (or your chosen alias) |

### 3. Update GitHub Actions Workflow

The workflow needs to decode the keystore and create `key.properties` before building. Add this before the build step:

```yaml
- name: Setup signing configuration
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
    cat > android/key.properties << EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=upload-keystore.jks
    EOF
```

## Security Best Practices

1. **Never commit** `key.properties` or `*.jks` files to Git (they're in `.gitignore`)
2. **Back up your keystore** to a secure location (encrypted USB drive, password manager, etc.)
3. **Use strong passwords** for keystore and key
4. **Don't share** your keystore or passwords
5. **Keep multiple backups** in different secure locations

## Troubleshooting

### "Failed to load keystore" Error

**Cause**: The `storeFile` path in `key.properties` is incorrect.

**Solution**: Use absolute path or ensure the path is correct relative to the `android/` directory.

### Build Works Locally but Fails in GitHub Actions

**Cause**: Keystore secrets not properly configured in GitHub.

**Solution**: 
1. Verify all secrets are added correctly in GitHub repository settings
2. Check the workflow logs for specific errors
3. Ensure base64 encoding/decoding is correct

### "Signature does not match" on Update

**Cause**: The new APK was signed with a different keystore than the installed version.

**Solution**: 
1. All updates must use the same keystore as the original installation
2. If you've lost your keystore, users must uninstall and reinstall
3. Going forward, keep your keystore backed up securely

### Users Still Need to Uninstall

**Cause**: The previously installed APK was signed with debug keystore or a different release keystore.

**Solution**:
1. Users with the old version will need to uninstall once
2. After installing the new properly-signed version, future updates will work seamlessly
3. Communicate this one-time requirement to your users

## What Changes When You Have a Keystore?

### Without key.properties (Fallback to Debug Signing)
- Uses debug keystore (different on each machine)
- Updates will fail
- Users must uninstall and reinstall

### With key.properties (Release Signing)
- Uses your custom release keystore
- Updates work seamlessly
- Users can update without uninstalling

## Migration Path for Existing Users

If you've already distributed APKs signed with debug keystore:

1. **Generate and configure your release keystore** (follow steps above)
2. **Increment the version code** in `pubspec.yaml` (e.g., from `1.0.0+1` to `1.0.1+2`)
3. **Build and distribute the new APK** with release signing
4. **Inform users**: They'll need to uninstall the old version once, then future updates will work
5. **Document this**: Add a notice in your app's update notes

## Version Management

Always increment version for updates:

In `pubspec.yaml`:
```yaml
version: 1.0.1+2
#        ↑     ↑
#        |     |
#        |     +-- versionCode (must increase for updates)
#        +-------- versionName (user-visible version)
```

Before releasing an update:
```yaml
# Old version
version: 1.0.0+1

# New version (increment the number after +)
version: 1.0.1+2
```

## Quick Reference

### Generate keystore (once):
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storetype JKS
```

### Create key.properties (once):
```bash
cat > android/key.properties << EOF
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
EOF
```

### Build signed release:
```bash
flutter build apk --release
```

### Verify APK is signed:
```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## Additional Resources

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Documentation](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Keystore Best Practices](https://developer.android.com/studio/publish/app-signing#secure-key)
