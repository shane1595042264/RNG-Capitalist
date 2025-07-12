# 📋 Microsoft Store Installer Parameters Guide

## 🔍 What are Installer Parameters?

**Installer parameters** are command-line switches that allow your installer to run in "silent mode" - meaning it installs automatically without user interaction. This is required for Microsoft Store automated deployment and enterprise installations.

## 🎯 For Your RNG Capitalist App

### ✅ **RECOMMENDED: Leave Empty**
For your self-extracting 7-Zip installer, you should:
- **Installer parameters field**: Leave **EMPTY** or put `/S`
- **Silent mode checkbox**: ✅ **CHECK** "Installer runs in silent mode but does not require switches"

### 🔧 **Why This Setup?**

Your 7-Zip self-extracting installer automatically supports:
- **Silent extraction**: Extracts files without user prompts
- **Automatic execution**: Runs the embedded batch script
- **Unattended installation**: No user interaction required

## 📝 **Common Installer Parameters (Reference)**

### For Different Installer Types:

#### **MSI Installers:**
```
/quiet /norestart
/passive /norestart
/qn /norestart
```

#### **NSIS Installers:**
```
/S
/SILENT
/VERYSILENT
```

#### **Inno Setup:**
```
/SILENT
/VERYSILENT /NORESTART
```

#### **7-Zip SFX (Your Type):**
```
/S          (silent extraction)
-o"path"    (output directory)
-y          (yes to all prompts)
```

## 🎯 **Your Microsoft Store Form:**

### **Field: "Installer parameters"**
**Enter**: `/S` or leave **empty**

### **Checkbox: "Installer runs in silent mode but does not require switches"**
**Check**: ✅ **YES** (recommended)

## 🔧 **How Silent Installation Works**

When Microsoft Store or enterprise admins install your app:

1. **Download**: Your installer is downloaded
2. **Silent Run**: Executed with parameters (if any)
3. **Automatic Install**: Installs without user prompts
4. **Completion**: Reports success/failure automatically

## 🛠️ **Enhanced Installer for Better Compatibility**

If you want perfect silent installation support, I can create an improved installer with explicit silent mode:

### **Option 1: Current Installer (Recommended)**
- Leave parameters empty
- Check "runs in silent mode but does not require switches"
- Works for most scenarios

### **Option 2: Enhanced Silent Installer**
- Add explicit `/S` parameter support
- Better enterprise compatibility
- More professional deployment

## 📋 **Quick Fill Guide**

For the Microsoft Store form:

```
Installer parameters: [LEAVE EMPTY]
☑️ Installer runs in silent mode but does not require switches
```

**OR**

```
Installer parameters: /S
☐ Installer runs in silent mode but does not require switches
```

## 🚀 **Why This Matters**

Silent installation is required for:
- ✅ **Microsoft Store** automated deployment
- ✅ **Enterprise** mass deployment
- ✅ **System administrators** bulk installation
- ✅ **IT departments** software management
- ✅ **Compliance** with corporate policies

## 🎯 **Best Practice Recommendation**

For your current installer:
1. **Leave "Installer parameters" EMPTY**
2. **Check** "Installer runs in silent mode but does not require switches"
3. This tells Microsoft Store your installer is already silent-compatible

Your 7-Zip self-extracting installer is designed to work silently by default! 🎉
