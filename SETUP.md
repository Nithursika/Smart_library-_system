# Smart Library — Step-by-step setup

## What you are building
- **Frontend:** Flutter Android app (`frontend/`) → install as APK on phone
- **Backend + DB:** Supabase (free hosted)

App works with **mock data** even before Supabase is connected.

---

## Step 1 — Flutter on this PC (already cloned if guided by agent)
Flutter SDK path used: `%USERPROFILE%\flutter`

Add to PATH (PowerShell, permanent for user):
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\flutter\bin", "User")
$env:Path = "$env:USERPROFILE\flutter\bin;$env:Path"
flutter doctor
```

Install **Android Studio**, accept licenses, create an emulator or plug in a phone with USB debugging.

---

## Step 2 — Run the app (UI first, no cloud needed)
```powershell
cd d:\SLM\Smart_library-_system\frontend
flutter pub get
flutter run
```

You should see Home → Find / All Books / Report Missing using sample books.

---

## Step 3 — Create free Supabase project
1. Go to https://supabase.com → Sign up → **New project**
2. Wait until project is ready
3. Open **SQL Editor** → paste contents of `supabase/schema.sql` → **Run**
4. Open **Project Settings → API**
5. Copy:
   - Project URL
   - `anon` `public` key

---

## Step 4 — Connect the app to Supabase
Edit `frontend/lib/config.dart`:

```dart
static const supabaseUrl = 'https://xxxx.supabase.co';
static const supabaseAnonKey = 'eyJhbGciOi...';
```

Save, then:
```powershell
flutter run
```

Now search / all books / report missing use the **cloud DB**.

---

## Step 5 — Build APK for the phone (demo anywhere)
```powershell
cd d:\SLM\Smart_library-_system\frontend
flutter build apk --release
```

APK path:
`frontend\build\app\outputs\flutter-apk\app-release.apk`

Copy to phone → install → open. Needs **internet** for Supabase.

---

## Demo checklist
- [ ] Supabase SQL ran and Table Editor shows books
- [ ] `config.dart` has real URL + anon key
- [ ] APK installed on phone
- [ ] Phone has mobile data / Wi‑Fi
- [ ] Search + All Books + Report Missing work

## Later (ESP32 LEDs)
App + DB demo does not need ESP32. LED lighting is a separate hardware step.
