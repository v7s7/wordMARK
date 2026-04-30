# WordMark — Setup Guide

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.19 | https://docs.flutter.dev/get-started/install |
| Xcode | ≥ 15 | Mac App Store |
| Android Studio | Latest | https://developer.android.com/studio |
| CocoaPods | Latest | `sudo gem install cocoapods` |
| Node.js | ≥ 18 | For Firebase CLI |
| Firebase CLI | Latest | `npm install -g firebase-tools` |

---

## Step 1 — Clone & Install

```bash
git clone <your-repo-url>
cd wordMARK
flutter pub get
```

---

## Step 2 — Add Firebase to iOS

1. Go to [Firebase Console](https://console.firebase.google.com) → **word-mark-e1006**
2. Click **Add app** → iOS
3. Bundle ID: `com.wordmark.app`
4. Download **GoogleService-Info.plist**
5. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. Drag `GoogleService-Info.plist` into `Runner/Runner/` in Xcode  
   ✅ Make sure "Copy items if needed" is checked

---

## Step 3 — Add Firebase to Android

1. Go to Firebase Console → **word-mark-e1006**
2. Click **Add app** → Android
3. Package name: `com.wordmark.app`
4. Download **google-services.json**
5. Place it at:
   ```
   android/app/google-services.json
   ```

---

## Step 4 — Update firebase_options.dart

After adding iOS and Android apps in Firebase, run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=word-mark-e1006
```

This overwrites `lib/firebase_options.dart` with the correct values for all platforms.

**OR** manually copy the values from Firebase Console:

- iOS: from `GoogleService-Info.plist` → `API_KEY`, `GOOGLE_APP_ID`
- Android: from `google-services.json` → `api_key[0].current_key`, `client[0].client_info.mobilesdk_app_id`

Edit `lib/firebase_options.dart` and replace the `REPLACE_WITH_*` placeholders.

---

## Step 5 — Enable Firebase Services

In the Firebase Console for **word-mark-e1006**:

### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Anonymous**

### Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Start in production mode**
3. Select a region (e.g., `us-central`)
4. After creation, go to **Rules** tab
5. Copy the contents of `firestore.rules` from this repo and click **Publish**

### Indexes (auto-created on first query, or add manually)
Firestore will prompt to create indexes when needed. Accept those prompts.

---

## Step 6 — Run the App

```bash
# iOS (requires Mac + Xcode)
flutter run -d ios

# Android
flutter run -d android

# Web (for testing Firebase config)
flutter run -d chrome
```

---

## Step 7 — Build for Release

### iOS (App Store)
```bash
flutter build ios --release
```
Then open Xcode → Product → Archive → Distribute App

### Android (Play Store)
```bash
flutter build appbundle --release
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── router.dart                  # GoRouter navigation
├── firebase_options.dart        # Firebase config (gitignored)
├── core/
│   ├── constants/app_theme.dart # Colors + themes
│   ├── models/                  # Data models
│   ├── services/                # Firebase + game logic
│   └── providers/               # Riverpod state
├── data/
│   ├── words_3/4/5/6.dart       # Word lists per length
│   └── puzzle_packs.dart        # Puzzle pack definitions
└── features/
    ├── home/                    # Home screen
    ├── game/                    # Shared game screen + widgets
    ├── daily/                   # Daily challenge mode
    ├── practice/                # Practice mode setup
    ├── puzzles/                 # Puzzle packs
    ├── duel/                    # Multiplayer duel
    ├── stats/                   # Statistics
    └── settings/                # App settings
```

---

## Monetization (future)

The app is architected for premium upsells:
- **Puzzles**: 5 free per pack → `puzzle.isFree` gate in `PuzzlePackScreen`
- **Daily archive**: 4 days free → premium for full history in `DailyScreen`
- **Premium flag**: `settingsProvider` can hold `isPremium` after purchase

Recommended: **RevenueCat** (free tier) for in-app purchase management on iOS + Android.
Add `purchases_flutter` package and wire `isPremium` to the settings provider.

---

## FAQ

**Q: The app crashes on startup**  
A: Most likely `firebase_options.dart` has placeholder values. Complete Step 4.

**Q: Duel rooms not found**  
A: Check Firestore rules are deployed (Step 5). Also check internet permission in AndroidManifest.xml.

**Q: Words not accepted**  
A: The word must be in the word list (`lib/data/words_N.dart`). Expand those lists to add more valid words.

**Q: How do I add more words?**  
A: Open `lib/data/words_5.dart` (or the appropriate file) and add lowercase words to the const list.

**Q: iOS build fails with pod errors**  
A: Run `cd ios && pod install --repo-update && cd ..` then retry.
