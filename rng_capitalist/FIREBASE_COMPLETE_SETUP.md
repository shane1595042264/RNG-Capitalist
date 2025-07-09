# Complete Firebase Setup Guide for RNG Capitalist

## Prerequisites
- Flutter SDK installed
- Google account
- Node.js installed (for Firebase CLI)

## Step-by-Step Setup

### 1. Install Firebase CLI
```powershell
npm install -g firebase-tools
```

### 2. Install FlutterFire CLI
```powershell
dart pub global activate flutterfire_cli
```

### 3. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `rng-capitalist`
4. Disable Google Analytics (optional)
5. Click "Create project"

### 4. Enable Services

#### Authentication:
1. Go to "Authentication" → "Sign-in method"
2. Enable "Google" provider
3. Add your app domains if needed

#### Firestore:
1. Go to "Firestore Database"
2. Click "Create database"
3. Start in "Test mode" initially
4. Choose your preferred location

### 5. Configure Flutter App

#### Option A: Automatic (Recommended)
```powershell
# In your project directory
firebase login
flutterfire configure
```

#### Option B: Manual
1. In Firebase Console, add your Flutter app
2. Download configuration files
3. Replace `lib/firebase_options.dart` with the generated file

### 6. Set Firestore Security Rules

In Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 7. Update Google Sign-In Configuration

#### For Windows:
No additional configuration needed - handled by Firebase Auth.

#### For Web (if deploying to web):
1. Get OAuth 2.0 Client ID from Google Cloud Console
2. Add it to your web configuration

### 8. Test the Setup

```powershell
flutter pub get
flutter run -d windows
```

## Firebase Free Tier Limits
- **Firestore**: 1 GB storage, 50K document reads/day, 20K writes/day
- **Authentication**: Unlimited users
- **Hosting**: 10 GB bandwidth/month (if using web)

## Troubleshooting

### Common Issues:

1. **"Firebase options not found"**
   - Run `flutterfire configure` again
   - Ensure `firebase_options.dart` is in `lib/` folder

2. **Google Sign-In not working**
   - Check that Google provider is enabled in Firebase Console
   - Verify OAuth configuration

3. **Firestore permission denied**
   - Update security rules as shown above
   - Ensure user is properly authenticated

### Debug Commands:
```powershell
flutter doctor
firebase --version
flutterfire --version
```

## Next Steps After Setup

1. Run the app: `flutter run -d windows`
2. Test Google Sign-In
3. Verify data sync between devices
4. Monitor usage in Firebase Console

## Data Migration

If you have existing local data, it will be migrated to cloud automatically on first sign-in.

## Security Best Practices

1. Never commit Firebase configuration files to public repos
2. Use environment variables for sensitive data
3. Regularly review Firestore security rules
4. Monitor Firebase Console for unusual activity

---

Need help? Check the [Firebase Documentation](https://firebase.google.com/docs) or create an issue in the project repository.
