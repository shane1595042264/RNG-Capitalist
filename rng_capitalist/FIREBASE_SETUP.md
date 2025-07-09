# Firebase Setup Guide for RNG Capitalist

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `rng-capitalist` (or any name you prefer)
4. Click "Continue"
5. Disable Google Analytics (optional for this project)
6. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Click on "Google" provider
3. Enable it and click "Save"
4. Note down the Web client ID for later use

## Step 3: Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in test mode" (we'll secure it later)
4. Choose a location (preferably closest to your users)
5. Click "Done"

## Step 4: Add Flutter App to Firebase

### For Windows App:
1. In Firebase Console, click "Add app" → Windows (Desktop)
2. Enter app name: `RNG Capitalist`
3. Click "Register app"
4. Download `firebase_options.dart` file
5. Place it in `lib/firebase_options.dart`

### For Web App (if you want web support):
1. Click "Add app" → Web
2. Enter app name: `RNG Capitalist Web`
3. Click "Register app"
4. Copy the config object (we'll use it later)

## Step 5: Security Rules for Firestore

In Firestore → Rules, replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 6: Get Configuration Files

After completing the setup, you'll need:
1. `firebase_options.dart` - Auto-generated configuration file
2. Web Client ID for Google Sign-In

## Step 7: Test the Setup

Once you've completed the above steps, come back and I'll help you integrate everything into the app!

---

**Important Notes:**
- Firebase has generous free tier limits (1 GB storage, 50k reads/day, 20k writes/day)
- Keep your configuration files secure
- Don't commit sensitive keys to version control
