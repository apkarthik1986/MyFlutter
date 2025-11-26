# Implementation Checklist - App Update Fix

Use this checklist to implement the app update fix in your environment.

## 📋 Pre-Implementation Checklist

- [ ] I have read [KEYSTORE_SETUP.md](KEYSTORE_SETUP.md)
- [ ] I have read [UPDATE_FIX_SUMMARY.md](UPDATE_FIX_SUMMARY.md)
- [ ] I understand the need for consistent signing
- [ ] I have backup plan for keystore (where to store it securely)

## 🔐 Keystore Generation (Local Development)

### Step 1: Generate Keystore
- [ ] Open terminal
- [ ] Run keystore generation command:
  ```bash
  keytool -genkey -v -keystore ~/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] Choose strong keystore password (write it down securely!)
- [ ] Choose strong key password (write it down securely!)
- [ ] Fill in your organization details
- [ ] Verify keystore was created: `ls -l ~/upload-keystore.jks`

### Step 2: Backup Keystore (CRITICAL!)
- [ ] Copy keystore to USB drive/external storage
- [ ] Store passwords in password manager
- [ ] Verify backup is readable
- [ ] Store backup in second location (different from primary)

### Step 3: Create key.properties
- [ ] Navigate to `android/` directory
- [ ] Copy `key.properties.example` to `key.properties`:
  ```bash
  cp android/key.properties.example android/key.properties
  ```
- [ ] Edit `android/key.properties`
- [ ] Replace `YOUR_KEYSTORE_PASSWORD_HERE` with actual keystore password
- [ ] Replace `YOUR_KEY_PASSWORD_HERE` with actual key password
- [ ] Update `storeFile` path to point to your keystore location
- [ ] Save file
- [ ] Verify file is NOT tracked by git: `git status` (should not show key.properties)

### Step 4: Test Local Build
- [ ] Clean previous builds: `flutter clean`
- [ ] Get dependencies: `flutter pub get`
- [ ] Build release APK: `flutter build apk --release`
- [ ] Verify build succeeds
- [ ] Check APK exists: `ls -l build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Test Installation
- [ ] Connect Android device via USB
- [ ] Enable USB debugging on device
- [ ] Install APK: `adb install build/app/outputs/flutter-apk/app-release.apk`
- [ ] Verify app installs successfully
- [ ] Launch app and verify it works

### Step 6: Test Update
- [ ] Make small change (e.g., edit a string in lib/main.dart)
- [ ] Increment version in pubspec.yaml:
  ```yaml
  # Change from: version: 1.0.1+2
  # Change to:   version: 1.0.2+3
  ```
- [ ] Build again: `flutter build apk --release`
- [ ] Install update: `adb install -r build/app/outputs/flutter-apk/app-release.apk`
- [ ] Verify update installs WITHOUT requiring uninstall
- [ ] Verify app still works after update

## ☁️ GitHub Actions Setup

### Step 1: Encode Keystore
- [ ] Navigate to directory containing keystore
- [ ] Encode to base64:
  ```bash
  # Linux/Mac:
  base64 -w 0 upload-keystore.jks > keystore-base64.txt
  
  # Windows PowerShell:
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File keystore-base64.txt
  ```
- [ ] Verify `keystore-base64.txt` was created
- [ ] Open file and verify it contains base64 text (long string of letters/numbers)

### Step 2: Add GitHub Secrets
- [ ] Go to GitHub repository in browser
- [ ] Click **Settings** tab
- [ ] Navigate to **Secrets and variables** → **Actions**
- [ ] Click **New repository secret**

Add these 4 secrets:

#### Secret 1: KEYSTORE_BASE64
- [ ] Name: `KEYSTORE_BASE64` (exactly as shown)
- [ ] Value: Copy entire contents of `keystore-base64.txt`
- [ ] Click **Add secret**

#### Secret 2: KEYSTORE_PASSWORD
- [ ] Name: `KEYSTORE_PASSWORD` (exactly as shown)
- [ ] Value: Your keystore password
- [ ] Click **Add secret**

#### Secret 3: KEY_PASSWORD
- [ ] Name: `KEY_PASSWORD` (exactly as shown)
- [ ] Value: Your key password (often same as keystore password)
- [ ] Click **Add secret**

#### Secret 4: KEY_ALIAS
- [ ] Name: `KEY_ALIAS` (exactly as shown)
- [ ] Value: `upload` (or your chosen alias)
- [ ] Click **Add secret**

### Step 3: Verify Secrets
- [ ] Confirm all 4 secrets are listed in Actions secrets page
- [ ] Secret names are exactly as specified (case-sensitive)
- [ ] Values are masked (shown as ***)

### Step 4: Delete Temporary Files
- [ ] Delete `keystore-base64.txt` from local machine
- [ ] Verify no keystore-related files in git: `git status`

### Step 5: Trigger GitHub Actions Build
- [ ] Go to **Actions** tab in GitHub
- [ ] Click **Build Flutter APK** workflow
- [ ] Click **Run workflow**
- [ ] Select branch: `main` or `master`
- [ ] Click **Run workflow**

### Step 6: Monitor Build
- [ ] Wait for workflow to start
- [ ] Click on the running workflow
- [ ] Monitor build progress
- [ ] Look for "Setup release signing" step (should show as green)
- [ ] Wait for "Build APK" to complete

### Step 7: Download and Test
- [ ] Scroll down to **Artifacts** section
- [ ] Download `myflutter-release-apk`
- [ ] Extract APK from zip file
- [ ] Install on device: `adb install path/to/app-release.apk`
- [ ] Verify app works

### Step 8: Test Update from CI
- [ ] Make small change and commit
- [ ] Increment version in pubspec.yaml
- [ ] Push to GitHub
- [ ] Wait for automatic build
- [ ] Download new APK
- [ ] Install as update: `adb install -r path/to/app-release.apk`
- [ ] Verify update works WITHOUT uninstalling

## 📱 User Communication (If App Already Distributed)

### Step 1: Prepare User Notice
- [ ] Draft update announcement
- [ ] Explain one-time reinstall requirement
- [ ] Mention future updates will work smoothly
- [ ] Provide download link

### Step 2: Distribute Notice
- [ ] Send email/notification to users
- [ ] Post on app website/blog
- [ ] Update app store listing (if applicable)

### Sample Notice:
```
Important Update - Action Required

We've improved the app update process! However, this one time you'll need to:

1. Uninstall the current version
2. Download and install the new version from [link]

After this, all future updates will work seamlessly without uninstalling!

We apologize for the inconvenience and thank you for your patience.
```

## 🔍 Troubleshooting

### Build Fails Locally
- [ ] Check `key.properties` exists in `android/` directory
- [ ] Verify all 4 properties are filled in
- [ ] Verify `storeFile` path is correct (use absolute path)
- [ ] Verify keystore file exists at specified path
- [ ] Try using absolute path in `storeFile`
- [ ] Check password is correct: 
  ```bash
  keytool -list -v -keystore upload-keystore.jks
  ```

### GitHub Actions Build Fails
- [ ] Verify all 4 secrets are added
- [ ] Check secret names match exactly (case-sensitive)
- [ ] Check workflow logs for specific error
- [ ] Look for "Setup release signing" step in logs
- [ ] Verify step is not skipped
- [ ] Re-encode keystore with `-w 0` flag:
  ```bash
  base64 -w 0 upload-keystore.jks > keystore-base64.txt
  ```

### Update Still Fails on Device
- [ ] Verify both APKs built with same keystore
- [ ] Check APK signatures match:
  ```bash
  jarsigner -verify -verbose -certs old-app.apk | grep "SHA-256"
  jarsigner -verify -verbose -certs new-app.apk | grep "SHA-256"
  ```
- [ ] If signatures differ, rebuild with correct keystore
- [ ] Ensure version code was incremented

### App Won't Install
- [ ] Enable "Install from unknown sources" on device
- [ ] Check device has enough storage
- [ ] Try uninstalling old version first
- [ ] Verify APK is not corrupted (re-download)

## ✅ Final Verification

### Local Development
- [ ] Can build APK successfully
- [ ] APK installs on device
- [ ] Updates work without uninstalling
- [ ] keystore backed up in 2+ locations
- [ ] Passwords stored in password manager
- [ ] key.properties not in git

### GitHub Actions
- [ ] All secrets configured
- [ ] Builds complete successfully
- [ ] "Setup release signing" step runs
- [ ] APK downloads from artifacts
- [ ] CI-built APK installs on device
- [ ] Updates work with CI-built APKs

### Documentation
- [ ] Keystore location documented
- [ ] Recovery procedure documented
- [ ] Team members know where to find keystore (if applicable)
- [ ] User communication sent (if app already distributed)

## 📝 Post-Implementation Notes

### Record These Details:
- **Keystore Location**: _______________________
- **Backup Location 1**: _______________________
- **Backup Location 2**: _______________________
- **Password Manager Entry**: _______________________
- **Key Alias Used**: upload (default)
- **Date Keystore Created**: _______________________
- **Date First Released**: _______________________

### Team Communication (if applicable):
- [ ] Team knows where keystore is stored
- [ ] Team knows how to access passwords
- [ ] Team knows not to create new keystore
- [ ] Team knows to increment version before release
- [ ] Team knows backup procedures

## 🎉 Success Criteria

You've successfully implemented the fix when:
- ✅ Local builds use release signing
- ✅ GitHub Actions builds use release signing
- ✅ Updates install without uninstalling
- ✅ Keystore is backed up securely
- ✅ Team (if applicable) knows procedures
- ✅ Users (if applicable) have been notified

## 📚 Reference Documentation

For more details, see:
- [KEYSTORE_SETUP.md](KEYSTORE_SETUP.md) - Detailed keystore guide
- [GITHUB_ACTIONS_SIGNING.md](GITHUB_ACTIONS_SIGNING.md) - CI/CD setup
- [UPDATE_FIX_SUMMARY.md](UPDATE_FIX_SUMMARY.md) - Technical details
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting

## ⚠️ Critical Reminders

1. **Never lose your keystore** - Without it, you cannot update your app
2. **Back up in multiple locations** - Hard drives fail, USB drives get lost
3. **Never commit key.properties or *.jks** - Already in .gitignore, but be careful
4. **Use strong passwords** - Your keystore secures your app's identity
5. **Increment version code** - Required for every update
6. **Test locally first** - Before configuring CI/CD

---

**Need Help?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or the specific setup guides.
