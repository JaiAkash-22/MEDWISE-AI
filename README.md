# MedWise AI — Starter Scaffold

This is a working Flutter project skeleton covering the **4 Must-Have
features** from the handbook: Medicine Scanner, OCR, AI Explanation, and
basic History. It follows the 12-Day Build Sprint's file structure.

## What's already built
- Full navigation: Splash → Home → Scan → Result, plus History and Settings
- Camera capture + Google ML Kit OCR (`lib/services/ocr_service.dart`)
- AI explanation service — **provider-agnostic**, you fill in the API
  endpoint/key (`lib/services/ai_service.dart`)
- Local save/history via shared_preferences (`lib/services/database_service.dart`)
- Voice read-aloud on the Result screen (flutter_tts)
- Safety disclaimer baked into the AI prompt and the Result screen UI

## What's stubbed for later days (per the sprint)
- Family Profiles (Day 8)
- Reminders (Day 7)
- Emergency QR (Day 8)
- Settings — text size / language (Day 9)

## Setup (do this first)
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. `cd medwise_ai`
3. `flutter pub get`
4. Connect a device or start an emulator
5. `flutter run`

## Before it will actually explain anything
Open `lib/services/ai_service.dart` and fill in:
- `apiUrl` — your chosen LLM API endpoint (Gemini, OpenAI, Claude, etc. all
  work — the handbook suggests Gemini's free tier to start)
- `apiKey` — your API key (load from environment/`--dart-define`, don't
  commit it to Git)
- Adjust the response-parsing line to match your provider's JSON shape

## Camera permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```
And to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>MedWise AI needs the camera to scan medicine labels.</string>
```

## Day-by-day from here (12-Day Sprint)
- **Day 7**: Build Reminders using `flutter_local_notifications` (already
  in pubspec.yaml) — add scheduled alerts tied to a saved Medicine.
- **Day 8**: Build Family Profiles (`lib/models/profile.dart` is ready) and
  Emergency QR using `qr_flutter` (already in pubspec.yaml) — encode a
  profile's name + notes into a QR code.
- **Day 9**: Wire up Settings (text scale, language) and do a full visual
  polish pass.
- **Day 10-12**: Test on real medicine strips, fix bugs, rehearse the demo.

## A note on the database choice
The handbook suggests Firebase/Supabase. This scaffold uses
`shared_preferences` (on-device only) instead, to get you to a working
demo fastest with zero backend setup. If you want cross-device sync,
swap `database_service.dart` for Firestore/Supabase calls later —
the rest of the app doesn't need to change since it only talks to that
one file.
