# LangarSeva

Find free langar (community kitchens) near you. Flutter app for Android and iOS, backed by Supabase.

- **Browse without login**: map + list of approved langars sorted by distance, "Open now" filter, timings, directions, call, share, donate (UPI / website).
- **Sign in** (phone OTP, Google, Apple) to add a langar, join seva slots and save favourites.
- **Community moderated**: submissions are `pending` until an admin approves them in-app.
- **Languages**: English, Hindi (हिन्दी), Punjabi (ਪੰਜਾਬੀ).

## Repo layout

```
lib/                 Flutter app (Riverpod + go_router + supabase_flutter)
  core/              env, Supabase client, location, open-now logic, distance, locale
  features/          langars (map/list/detail), submit, auth, seva, donate, profile, admin
  l10n/              app_en.arb, app_hi.arb, app_pa.arb (+ generated app_localizations*.dart)
supabase/
  migrations/        0001_init.sql – schema, RLS, nearby_langars RPC, storage bucket
  seed.sql           15 well-known langars with timings
android/ ios/        native shells (package id com.langarseva.app)
.github/workflows/   CI: analyze + test + debug APK on every push, signed AAB on main/tags
codemagic.yaml       iOS → TestFlight and Android → Play builds (no Mac needed)
store/               Play / App Store listings (en/hi/pa), graphics, tester invite
docs/                privacy policy + terms (publish with GitHub Pages)
```

## 1. Backend setup (once)

1. Create a Supabase project (region `ap-south-1`).
2. SQL editor → run `supabase/migrations/0001_init.sql`, then `supabase/seed.sql`.
3. **Auth → Providers**: enable **Phone** (choose an SMS provider: MSG91 or Twilio), **Google** and **Apple**.
   - For App Store review add a test OTP: Auth → Phone → "Test phone numbers": `+919999999999 = 123456`.
4. **Auth → URL configuration**: add redirect URL `com.langarseva.app://login-callback`.
5. Make yourself admin: `update public.profiles set role = 'admin' where phone = '+91...';`
6. Note the **Project URL** and **anon / publishable key** (Settings → API).

### Google Maps keys
Google Cloud Console → enable *Maps SDK for Android* and *Maps SDK for iOS* → create two API keys restricted to
`com.langarseva.app` (Android: add SHA-1 of your debug and upload keystores; iOS: bundle id).

### Google sign-in
Google Cloud → Credentials → OAuth client IDs: **Web** (paste its id/secret into Supabase Google provider; this is `GOOGLE_WEB_CLIENT_ID`),
**Android** (package + SHA-1) and **iOS** (bundle id → `GOOGLE_IOS_CLIENT_ID`; also add its reversed id as a URL scheme in `ios/Runner/Info.plist`).

## 2. Run locally

```bash
flutter pub get
flutter gen-l10n
MAPS_API_KEY=<android maps key> flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com
```

Checks: `flutter analyze && flutter test`.

## 3. Release checklist

### One-time
- [ ] Generate upload keystore: `keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
      and create `android/key.properties` from `android/key.properties.example` (both are git-ignored).
- [ ] GitHub → Settings → Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`, `MAPS_API_KEY_ANDROID`,
      `ANDROID_KEYSTORE_BASE64` (`base64 -w0 upload-keystore.jks`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`,
      `PLAY_SERVICE_ACCOUNT_JSON`; Variables: `RELEASE_SIGNING=true`.
- [ ] GitHub → Settings → Pages → deploy from `docs/` so the privacy policy URL works.
- [ ] Play Console: create app, fill listing from `store/play/`, Data safety, content rating, set up **Play App Signing**.
- [ ] App Store Connect: register bundle id `com.langarseva.app`, create app, fill listing from `store/appstore/`, create an API key.
- [ ] Codemagic: add repo, App Store Connect integration `langarseva_asc`, env groups listed at the top of `codemagic.yaml`, set `APP_STORE_APPLE_ID`.

### Every release
1. Bump `version:` in `pubspec.yaml` (`1.0.1+2` – build number must increase) and update `CHANGELOG.md`.
2. Merge to `main`, then tag: `git tag v1.0.1 && git push --tags`.
   - GitHub Actions builds the AAB and uploads it to the Play **internal** track.
   - Codemagic builds the IPA and uploads it to **TestFlight**.
3. Test on real devices from internal / TestFlight.
4. Play: promote internal → closed (first time: 12+ testers for 14 days) → production.
   App Store: TestFlight → "Submit for review" → release.

## Admin
Admins (`profiles.role = 'admin'`) see **Profile → Admin** with the pending queue. Approve/reject with one tap.
