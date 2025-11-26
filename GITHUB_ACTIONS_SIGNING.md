# GitHub Actions Release Signing Setup

This guide explains how to configure GitHub Actions to build APKs signed with your release keystore, enabling seamless app updates.

## Overview

By default, GitHub Actions builds APKs signed with debug keys. This causes update issues because each build has a different signature. This guide shows you how to use your release keystore in GitHub Actions.

## Prerequisites

1. You've generated a release keystore (see [KEYSTORE_SETUP.md](KEYSTORE_SETUP.md))
2. You have access to your repository settings on GitHub
3. You have your keystore file and passwords ready

## Step-by-Step Setup

### Step 1: Encode Your Keystore to Base64

GitHub Secrets can only store text, not binary files. We need to convert the keystore to base64:

**On Linux/Mac:**
```bash
base64 -i upload-keystore.jks -o keystore-base64.txt
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File keystore-base64.txt
```

**On Windows (Git Bash):**
```bash
base64 -w 0 upload-keystore.jks > keystore-base64.txt
```

This creates a `keystore-base64.txt` file with your encoded keystore.

### Step 2: Add Secrets to GitHub Repository

1. **Go to your repository on GitHub**
2. **Click Settings** (in the repository menu)
3. **Navigate to Secrets and variables → Actions**
4. **Click "New repository secret"**

Add these four secrets:

#### Secret 1: KEYSTORE_BASE64
- **Name**: `KEYSTORE_BASE64`
- **Value**: Copy and paste the entire contents of `keystore-base64.txt`
- Click **Add secret**

#### Secret 2: KEYSTORE_PASSWORD
- **Name**: `KEYSTORE_PASSWORD`
- **Value**: Your keystore password (the one you chose when creating the keystore)
- Click **Add secret**

#### Secret 3: KEY_PASSWORD
- **Name**: `KEY_PASSWORD`
- **Value**: Your key password (usually the same as keystore password)
- Click **Add secret**

#### Secret 4: KEY_ALIAS
- **Name**: `KEY_ALIAS`
- **Value**: `upload` (or whatever alias you used when creating the keystore)
- Click **Add secret**

### Step 3: Verify Workflow Configuration

The workflow file (`.github/workflows/build-apk.yml`) should already be configured. Verify it contains:

```yaml
- name: Setup release signing
  if: ${{ secrets.KEYSTORE_BASE64 != '' }}
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
    cat > android/key.properties << EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=upload-keystore.jks
    EOF

- name: Build APK
  run: flutter build apk --release
```

### Step 4: Trigger a Build

You can trigger a build by:

1. **Pushing to main/master branch:**
   ```bash
   git add .
   git commit -m "Configure release signing"
   git push
   ```

2. **Manual workflow dispatch:**
   - Go to **Actions** tab in GitHub
   - Click on **Build Flutter APK** workflow
   - Click **Run workflow**
   - Select branch and click **Run workflow**

### Step 5: Verify Signed APK

After the workflow completes:

1. Go to the workflow run
2. Download the APK from **Artifacts**
3. Install on a device
4. Future updates should work without uninstalling!

## How It Works

### With Secrets Configured:
1. Workflow decodes the base64 keystore
2. Creates `key.properties` file with your credentials
3. Build.gradle detects `key.properties` and uses release signing
4. APK is signed with your release keystore

### Without Secrets:
1. `key.properties` is not created
2. Build.gradle falls back to debug signing
3. APK works but updates will fail

## Security Notes

### What's Safe:
- ✅ Keystore is never committed to repository
- ✅ Passwords are encrypted in GitHub Secrets
- ✅ Secrets are not exposed in logs
- ✅ Only repository admins can view/edit secrets

### Best Practices:
1. **Limit access**: Only give repository access to trusted collaborators
2. **Use strong passwords**: For both keystore and GitHub account
3. **Enable 2FA**: On your GitHub account
4. **Audit access**: Regularly review who has access to your repository
5. **Backup keystore**: Keep secure offline backups

### What GitHub Logs Show:
```
Setup release signing
Run echo "***" | base64 -d > android/app/upload-keystore.jks
# Passwords are masked with ***
```

## Troubleshooting

### Build Fails with "Invalid keystore format"

**Cause**: Base64 encoding/decoding issue.

**Solution**:
1. Ensure you copied the entire base64 string
2. Try encoding again with `-w 0` flag (Linux):
   ```bash
   base64 -w 0 upload-keystore.jks > keystore-base64.txt
   ```
3. Check for extra whitespace in the secret value

### Build Succeeds but Updates Still Fail

**Cause**: Secrets not configured, still using debug signing.

**Solution**:
1. Verify all 4 secrets are added in GitHub
2. Check workflow logs for "Setup release signing" step
3. If step is skipped, secrets are not detected

### "Unable to read keystore" Error

**Cause**: Incorrect password or alias.

**Solution**:
1. Verify `KEYSTORE_PASSWORD` matches your actual keystore password
2. Verify `KEY_PASSWORD` matches your key password
3. Verify `KEY_ALIAS` matches the alias from keystore creation
4. Test locally first with `key.properties` before configuring GitHub

### Secrets Not Found in Workflow

**Cause**: Secret names don't match workflow file.

**Solution**:
Ensure secret names are exactly:
- `KEYSTORE_BASE64` (not Keystore_Base64 or keystore_base64)
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`

Secret names are case-sensitive!

## Testing the Setup

### Test Locally First

Before configuring GitHub Actions, test locally:

1. Create `android/key.properties` with your values
2. Run `flutter build apk --release`
3. Install APK on device
4. Make a small change
5. Increment version in `pubspec.yaml`
6. Build again and test update

If local updates work, GitHub Actions should work too.

### Verify APK Signature

Check if APK is properly signed:

```bash
# Extract certificate from APK
unzip -p app-release.apk META-INF/*.RSA | keytool -printcert

# Or use jarsigner
jarsigner -verify -verbose -certs app-release.apk
```

Compare the certificate between builds - they should match!

## Updating Your Keystore

If you need to use a different keystore:

1. **Generate new keystore**
2. **Encode to base64**
3. **Update GitHub Secrets** with new values
4. **Increment version** significantly (e.g., 1.0.0+1 → 2.0.0+100)
5. **Inform users**: They'll need to uninstall and reinstall once

**Warning**: Never lose your original keystore if you have users. They won't be able to update!

## Version Management for Updates

Always increment version before releasing:

```yaml
# In pubspec.yaml

# Before update
version: 1.0.0+1

# After update
version: 1.0.1+2
```

The number after `+` is the version code (must increase).

## Cleanup

After setting up secrets:

1. **Delete** `keystore-base64.txt` from your local machine
2. **Never commit** keystore files or `key.properties`
3. **Verify** `.gitignore` includes:
   ```
   *.jks
   *.keystore
   key.properties
   ```

## Benefits of This Setup

### Before (Debug Signing):
- ❌ Different signature each build
- ❌ Users must uninstall to update
- ❌ Updates fail with "App not installed"
- ❌ Poor user experience

### After (Release Signing):
- ✅ Consistent signature every build
- ✅ Seamless updates
- ✅ Professional app distribution
- ✅ Happy users

## Additional Resources

- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

## Quick Command Reference

### Encode keystore:
```bash
base64 -w 0 upload-keystore.jks > keystore-base64.txt
```

### Test signing locally:
```bash
flutter build apk --release
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

### Update version:
```bash
# Edit pubspec.yaml, increment version code
# Example: 1.0.0+1 → 1.0.1+2
flutter clean
flutter pub get
flutter build apk --release
```

### Verify secrets are set:
1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Should see 4 secrets listed (values are hidden)

## Checklist

Before releasing your first properly-signed update:

- [ ] Keystore generated and backed up securely
- [ ] Keystore encoded to base64
- [ ] All 4 secrets added to GitHub repository
- [ ] Workflow file includes signing step
- [ ] Test build triggered in GitHub Actions
- [ ] APK downloaded and verified
- [ ] Version code incremented
- [ ] Update tested on a device
- [ ] Users notified about one-time reinstall requirement (if applicable)

Once this is complete, all future updates will work seamlessly! 🎉
