# ECHO - Hearing Awareness & Preliminary Screening App

ECHO is a mobile hearing awareness and preliminary screening application built with Flutter, designed with a pure monochromatic light-blue aesthetic, strict accessibility (WCAG AA), and robust text-scale resilience.

> **Important Disclosure**: ECHO provides non-clinical preliminary sound screening and illustrative acoustic exposure estimates. All metrics, thresholds, and charts in this release are **Sample data and UI-only**. ECHO does not provide diagnostic medical evaluations or clinical hearing assessments.

---

## Technology Stack

- **Framework**: Flutter `3.44.4` (Channel stable)
- **Language**: Dart `3.12.2` (SDK `^3.12.0`)
- **State Management**: `flutter_riverpod: ^2.6.1`
- **Routing**: `go_router: ^14.8.1` (Canonical 36-route inventory)
- **Visualization**: `fl_chart: ^0.68.0`
- **Typography**: Geometric Sans (`DM Sans` regular, medium, semibold, bold)
- **Design Tokens**: Pure monochromatic single-hue palette (`~210°` light-blue, `AppColors`)

---

## Architecture & Linked Features

1. **"Split Horizon" Launch Intro (`EchoSplashGate`)**:
   - Cold-start intro overlay mounted at the root `MaterialApp.router` builder (zero impact on the 36-route table).
   - Inverted split horizon: 50/50 dual-clipped geometry with a 2dp horizon line.
   - 60ms staggered "ECHO" wordmark reveal, acoustic ghost echo trails, and tagline *"Listen with awareness"*.
   - Lifecycle: 1.8s minimum display hold, dismisses on initialization resolution, 4.0s hard cap, and interactive tap-to-skip.
   - Accessibility: Dedicated `MediaQuery.disableAnimations` path (static frame hold ~800ms with instant cut) and accessible announcement (`SemanticsService.sendAnnouncement`).

2. **"Soft Tint" Atmospheric Backdrop (`EchoBackdrop`)**:
   - Lightweight ambient depth behind every screen using a static `CustomPainter` with 3 subtle radial tints and faint acoustic wave arcs.
   - Guaranteed contrast: worst-case blended pixel luminance is $\ge 0.84$ (`#FFE9F2FA`), ensuring WCAG AA ($\ge 4.5:1$) contrast for all text layers.
   - Scaffolds are transparent while cards, dialogs, and sheets maintain crisp opaque surfaces.
   - Optional slow drift (<16dp travel over 60s, disabled by default in test suites and frozen under Reduce Motion).

3. **Coordinated Reveal (Stage 3 Integration)**:
   - Root hierarchy: `EchoResponsiveFrame` > `EchoBackdrop` > `Navigator` > `EchoSplashGate`.
   - Coordinated 400ms fade: as the top blue half retracts upward, `EchoBackdrop` fades in from 0% to 100% opacity (`Curves.easeOut`). Under Reduce Motion, the backdrop renders instantly at full opacity without fade.

---

## How to Run

### Run Locally (Chrome Web / Desktop / Device)
```bash
# Get dependencies
flutter pub get

# Run on available device or Chrome
flutter run -d chrome
```

### Component Gallery Mode
To inspect all buttons, cards, typography tokens, status indicators, and live 1.0x vs 2.0x text scaling:
```bash
# In lib/main.dart, launch with showGallery: true:
# EchoApp(showGallery: true)
```

---

## How to Build the Release APK

```bash
flutter build apk --release
```

- **Output Location**: `build/app/outputs/flutter-apk/app-release.apk`
- **File Size**: ~49.0 MB (51,421,913 bytes)
- **Signing**: Uses Android debug signing configuration (`signingConfigs.getByName("debug")`) because no custom keystore is configured. No keystores are created or committed to the repository.

---

## Testing & Quality Assurance

### Run the Full Test Suite (102 Tests)
```bash
flutter test
```
All 102 tests pass cleanly across unit, widget, token, and layout suites:
- `test/unit/`: Canonical 36-route GoRouter inventory, route precedence, redirect loops, hearing test state machine.
- `test/widget/`: Backdrop pixel contrast sampling ($\ge 4.5:1$), splash gate lifecycle & timing, backdrop reveal opacity, router state preservation, bottom nav sliding pill, 200% text-scale resilience.
- `test/tokens/`: Monochromatic hue compliance scan, zero forbidden color literals, WCAG 1.4.11 boundary checks.

### Run Static Analysis
```bash
flutter analyze
```
Zero lint warnings or analyzer errors.

### Visual Review Screenshots
Screenshot generation tests write to the repo-relative `build/review/` directory:
```bash
flutter test test/golden/
```

---

## Known Limitations

1. **Phase 4 Visuals Deferred**:
   - The active-ear spatial graphic and six-segment frequency progress bar in the screening flow were scheduled for Phase 4 and are **not built** in this release.
2. **Onboarding Real Screens vs. App Stub Screens**:
   - **All 7 Onboarding Screens are REAL & Fully Functional**:
     1. `WelcomeScreen` (`/welcome`)
     2. `AuthScreen` (`/auth` - Email/password validation, Sign in, Sign up, Guest mode)
     3. `ProfileSetupScreen` (`/profile-setup` - Age bracket, prior checks, listening environment)
     4. `DisclaimerScreen` (`/disclaimer` - Mandatory non-clinical checkbox gate)
     5. `PermissionsScreen` (`/permissions` - Microphone & notification permission cards)
     6. `DeviceSetupScreen` (`/device-setup` - Headphone verification, volume calibration slider, checklist)
     7. `OnboardingTestIntroScreen` (`/onboarding-test-intro` - Baseline screening gate)
   - **Remaining Stub Screens**:
     - **History**: `/history/compare`, `/history/reminders`, `/history/:testId`
     - **Monitoring**: `/monitoring/exposure`, `/monitoring/settings`
     - **Personalization**: `/personalization/equalizer`, `/personalization/enhancement`, `/personalization/saved`
     - **Profile**: `/profile/devices`, `/profile/notifications`, `/profile/privacy`, `/profile/export`, `/profile/about`, `/profile/help`
     - **Reports**: `/reports/weekly`, `/reports/exposure`, `/reports/insights`, `/reports/historical`
3. **Provisional Design Tokens**:
   - `AppTypography.wordmark`: Added as a provisional display token (56sp Bold 700, line-height 1.0, tracking 0.0) specifically for the "ECHO" splash wordmark. It sits outside the standard body text scale.
