# MyFlutter - Jewel Calc

A Flutter Android application for jewellery invoicing that can be built using GitHub Codespaces and GitHub Actions.

## 🎯 **[→ How to Build APK File](HOW_TO_BUILD_APK.md)** ← Start Here!

## 📖 Documentation

- **[How to Build APK](HOW_TO_BUILD_APK.md)** - **Start here!** Simple guide to build your APK
- **[Keystore Setup Guide](KEYSTORE_SETUP.md)** - **Important!** Enable seamless app updates
- **[Quick Start Guide](QUICKSTART.md)** - Get started in 5 minutes
- **[Detailed Building Instructions](BUILDING.md)** - Complete build guide
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Fix common issues
- **[GitHub Actions Workflows](.github/workflows/README.md)** - CI/CD documentation

## ⚠️ Important: App Update Fix

**Problem**: App updates were failing, requiring users to uninstall and reinstall.

**Solution**: This has been fixed! The app now supports seamless updates without uninstalling.

**For Developers**: To enable seamless updates, you need to set up release signing. See **[Keystore Setup Guide](KEYSTORE_SETUP.md)** for instructions.

**For Current Users**: The next update may require a one-time uninstall and reinstall. After that, all future updates will work seamlessly!

---

## 💎 Features

### Jewellery Invoicing Application
- **Multiple Gold Types Support**: Calculate for Gold 22K/916, 20K/833, 18K/750, and Silver
- **Separate Wastage Settings**: Different wastage percentages for gold and silver
- **Real-time Calculations**: Automatic calculation of jewellery amounts, making charges, and GST
- **Discount Options**: Apply discounts in rupees or percentage
- **Configurable Base Values**: Easily adjust gold/silver rates, wastage percentages, and making charges
- **Customer Information**: Capture bill number, customer details, and contact information
- **PDF Invoice Generation**: Generate professional invoices with thermal printer support
- **Daily Persistence**: Base values persist throughout the day and automatically reset at midnight
- **Material Design 3**: Clean, modern Android interface
- **Automated builds via GitHub Actions**
- **Development environment ready in GitHub Codespaces**

## 📖 How to Use

### Configure Base Values
1. Open the app and tap the **Settings** icon (⚙️) in the app bar
2. Set metal rates for different gold purities and silver
3. Configure wastage percentages for gold and silver
4. Set making charges per gram for gold and silver
5. Tap **Save** to store your configuration

**Note**: Base values persist throughout the day and automatically reset to zero at midnight.

### Create an Estimate

#### Step 1: Enter Customer Information
- Expand the "Customer Information" section
- Fill in bill number, account number, customer name, address, and mobile number

#### Step 2: Calculate Item Details
1. **Select Type**: Choose from Gold 22K/916, 20K/833, 18K/750, or Silver
2. **Enter Weight**: Input the gross weight in grams
3. **Enter Wastage**: Wastage is auto-calculated based on settings (can be adjusted)
4. **Review Net Weight**: Automatically calculated (Weight + Wastage)

#### Step 3: Configure Making Charges
- Choose between "Rupees" or "Percentage" mode
- System applies minimum making charges (₹250 for gold, ₹200 for silver)
- Adjust manually if needed

#### Step 4: Apply Discount (Optional)
- Select discount type: None, Rupees, or Percentage
- Enter discount amount or percentage
- View amount after discount

#### Step 5: Review and Generate Invoice
- Review CGST and SGST (1.5% each)
- Check final amount including GST
- Tap **Download PDF** to generate and share invoice

## 🎯 Calculation Formula

```
Net Weight = Gross Weight + Wastage
J Amount = Net Weight × Rate per gram
Subtotal = J Amount + Making Charges
Amount After Discount = Subtotal - Discount
CGST = Amount After Discount × 1.5%
SGST = Amount After Discount × 1.5%
Total Amount = Amount After Discount + CGST + SGST
```

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
│   └── main.dart          # Main Flutter application - Jewel Calc
├── test/                   # Test files
├── pubspec.yaml           # Flutter dependencies
└── README.md              # This file
```

## 🔧 Configuration

- **Flutter Version**: 3.24.3
- **Dart SDK**: >=3.2.0 <4.0.0
- **Min Android SDK**: 21 (Android 5.0)
- **Target Android SDK**: 34 (Android 14)

### Default Values

- Gold 22K/916: ₹0/gram (configurable in settings)
- Gold 20K/833: ₹0/gram (configurable in settings)
- Gold 18K/750: ₹0/gram (configurable in settings)
- Silver: ₹0/gram (configurable in settings)
- Gold Wastage: 0% (configurable in settings)
- Silver Wastage: 0% (configurable in settings)
- Gold Making Charges: ₹0/gram (configurable in settings)
- Silver Making Charges: ₹0/gram (configurable in settings)
- Minimum Gold MC: ₹250
- Minimum Silver MC: ₹200
- GST: 3% (1.5% CGST + 1.5% SGST)

All base values are automatically saved and persist throughout the day. They reset to zero at midnight for fresh daily configuration.

## 💾 Data Persistence

The application automatically saves your base values (metal rates, wastage percentages, and making charges) to local storage using SharedPreferences. This ensures that:

- **Your settings persist** across app restarts
- **Values are maintained** throughout the entire day
- **Automatic reset** occurs at midnight (based on system time)
- **No manual intervention** needed - the app handles everything automatically

## 📝 License

This is a jewellery invoicing application for personal and commercial use.