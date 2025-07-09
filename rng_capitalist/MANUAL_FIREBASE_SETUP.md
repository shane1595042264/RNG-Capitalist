# Manual Firebase Setup Steps

## Step 1: Create Firebase Project (Manual)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Click "Add project"**
3. **Project name**: `RNG Capitalist`
4. **Project ID**: `rng-capitalist-[random]` (Firebase will suggest)
5. **Disable Google Analytics** (optional)
6. **Click "Create project"**

## Step 2: Enable Authentication

1. **In Firebase Console, go to "Authentication"**
2. **Click "Get started"**
3. **Go to "Sign-in method" tab**
4. **Click on "Google"**
5. **Toggle "Enable"**
6. **Click "Save"**

## Step 3: Enable Firestore Database

1. **In Firebase Console, go to "Firestore Database"**
2. **Click "Create database"**
3. **Select "Start in test mode"**
4. **Choose your location** (closest to you)
5. **Click "Done"**

## Step 4: Add Flutter App to Firebase

1. **In Firebase Console, click the settings gear icon**
2. **Click "Project settings"**
3. **Scroll to "Your apps" section**
4. **Click the Flutter icon (</>) to add a Flutter app**
5. **App nickname**: `RNG Capitalist`
6. **Windows package name**: `com.example.rng_capitalist`
7. **Click "Register app"**
8. **Download the config file** (it will be a JSON-like configuration)
9. **Click "Continue to console"**

## Step 5: Update Security Rules

1. **Go to Firestore Database**
2. **Click "Rules" tab**
3. **Replace the rules with:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

4. **Click "Publish"**

## Step 6: Get Configuration Values

After registering your app, you'll see a configuration object. Copy these values:

- `apiKey`
- `authDomain`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

## Next Steps

Once you have these values, I'll help you update the firebase_options.dart file with your actual configuration!
