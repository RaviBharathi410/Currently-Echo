# ECHO Architectural & Technical Decisions Log

## ADR-001: Monochromatic Light-Blue Design Tokens & WCAG 1.4.11 Compliance
- **Date**: 2026-10-22
- **Context**: The app enforces a strict single-hue monochromatic palette (~210° blue) with zero red, green, yellow, orange, or pink anywhere in the app. Statuses must be communicated via icon + label + tonal styling.
- **Decision**:
  - `AppColors.blue400` (`#3B8ED8`, luminance $0.2523$) provides a **3.47:1** contrast ratio against pure white and **3.25:1** against surface `#F4F8FC`, satisfying WCAG 2.1 Criterion 1.4.11 for user interface components and graphical boundaries.
  - `AppColors.blue500` was darkened to `#1967B3` (luminance $0.1316$), providing a **4.90:1** contrast ratio on `AppColors.blue100` (`#E1EEFA`, luminance $0.8406$) and **5.78:1** on white, strictly satisfying WCAG AA ($\ge$ 4.5:1) for secondary button labels and active bottom nav labels.
  - `ColorScheme.error` is explicitly overridden with `AppColors.blue500` (and `onError` with `AppColors.white`) to prevent Flutter's default Material red error styling.
- **Consequences**: Strict mathematical compliance verified algorithmically in `design_tokens_test.dart` for all real text and background pairs.

## ADR-002: CardThemeData for Pinned Flutter Version (Flutter >= 3.27.0)
- **Date**: 2026-10-22
- **Context**: `CardThemeData` was introduced and stabilized in Flutter 3.27+. Pinned SDK to `sdk: ">=3.6.0 <4.0.0"` and `flutter: ">=3.27.0"`.
- **Decision**: Used `CardThemeData` in `AppTheme.light` and pinned Flutter $\ge$ 3.27.0 in `pubspec.yaml`.
- **Consequences**: Zero deprecation warnings and future-proof theme composition.

## ADR-003: Spacing Grid and `p6` Definition
- **Date**: 2026-10-22
- **Context**: Ear pill tags and compact badges required vertical padding of 6.0dp, which was missing from the base 4/8dp grid.
- **Decision**: Explicitly added `static const double p6 = 6.0;` to `AppSpacing`.
- **Consequences**: Eliminated magic numbers across badges, chips, and tags.

## ADR-004: Text-Scale Resilience & Semantic Deduplication
- **Date**: 2026-10-22
- **Context**: Wrapping cards or app bars with outer labels while children also contain text causes duplicate screen reader announcements. In bottom nav, `FittedBox` defeats text scaling by shrinking text below 12sp.
- **Decision**:
  - In `EchoButton`: Removed `Center.mainAxisSize`, added `Flexible` with `maxLines: 2`, and wrapped child row with `ExcludeSemantics`.
  - In `EchoCard`: Added `MergeSemantics` when `semanticLabel == null`, and `excludeSemantics: true` on `Semantics` when `semanticLabel != null` to announce only the summary label.
  - In `EchoAppBar`: Put `Semantics(header: true)` on the title `Text` only, removing redundant outer header semantics.
  - In `EchoBottomNav`: Shortened labels to `Test`, `Home`, `Monitor`, `Reports`, `Profile`, clamped text scaling to 1.0–1.3, removed `FittedBox`, and added tooltips and full accessible labels.
- **Consequences**: 100% compliance with Flutter `meetsGuideline` accessibility matchers.

## ADR-005: Non-Clinical Preliminary Screening Terminology
- **Date**: 2026-10-22
- **Context**: Mobile phones without calibrated acoustic hardware cannot ethically or legally claim diagnostic hearing threshold measurement (`dB HL`).
- **Decision**:
  - Replaced all occurrences of `dB HL` with uncalibrated **"Relative Sound Level (Level 1–13)"**.
  - Renamed chart components to `ScreeningResultsChart`.
  - Replaced headline threshold terms with **"Tone response pattern (Estimated)"** and **"Recommended daily listening guide (Estimated)"**.
  - Replaced "Emergency/Pause" with **"Pause test"**.
- **Consequences**: Strict adherence to non-clinical, preliminary health screening regulations.

## ADR-006: Canonical 36-Route Inventory Structure
- **Date**: 2026-10-22
- **Context**: ECHO contains 5 shell tabs, 7 onboarding steps, 3 top-level test modal routes, and nested sub-routes for monitoring, reports, profile, history, and audio personalization.
- **Decision**: Reconciled the canonical route inventory to exactly 36 routes across all documentation, tests, and router configuration. Modal test routes (`/test/in-progress`, `/test/paused`, `/test/results`) sit on root navigator to hide bottom navigation during screening. History sub-routes are ordered so static segments precede parameterized `:testId`. Exit behavior during test pause routes according to onboarding completion state.
- **Consequences**: Exact 1-to-1 match between specification, route table, router implementation, and route verification tests.

## ADR-007: Golden Test Baseline Commitment Policy
- **Date**: 2026-10-22
- **Context**: Visual regression testing requires committed golden image files (`.png` baselines). However, tokens and components are evolving prior to final Figma token import.
- **Decision**: The current screenshot test generates visual verification artifacts (`gallery_1_0x.png` and `gallery_2_0x.png`) for inspection and review. Real golden comparison tests with committed git pixel baselines (via `alchemist` or `matchesGoldenFile`) are explicitly deferred until final Figma design tokens and component specs are frozen and imported into the design system.
- **Consequences**: Avoids brittle churn on intermediate golden PNG files while preserving full test-scale resilience testing and manual visual inspection artifacts.

## ADR-008: Reconciled Unauthenticated Route Redirection Policy
- **Date**: 2026-10-22
- **Context**: Disambiguation was needed regarding the unauthenticated landing route (`/welcome` vs `/auth`) to avoid circular redirect loops while preserving public onboarding introduction.
- **Decision**:
  - `/welcome` is designated as the public first-launch entry route (`initialLocation` when user is not onboarded). Unauthenticated users on `/welcome` are never redirected.
  - `/auth` is designated as the public authentication screen. Unauthenticated users on `/auth` are never redirected.
  - Any unauthenticated attempt to access protected authenticated routes (`/dashboard`, `/profile-setup`, `/test`, etc.) redirects to `/auth`.
  - Once authenticated, accessing `/welcome` or `/auth` redirects to `/dashboard` (if onboarded) or `/profile-setup` (if onboarding is incomplete).
- **Consequences**: Zero circular redirect loops, full support for guest/auth entry, and consistent protection across all 36 routes.

## ADR-009: Onboarding Resumption & Drop-off Flow
- **Date**: 2026-10-22
- **Context**: When an authenticated user exits the application mid-onboarding (e.g., at `/disclaimer`, `/permissions`, or `/device-setup`) before completing the initial hearing check, the app must determine where to route them upon re-entry.
- **Decision**: Authenticated users with incomplete onboarding (`isOnboardingComplete == false`) are routed to `/profile-setup` when attempting to access `/welcome` or `/auth`. `/profile-setup` serves as the canonical onboarding root, ensuring user identity and profile metadata are established before advancing to device and system permissions. Fine-grained step restoration will be managed by the onboarding persistence provider in Phase 2.
- **Consequences**: Clean, deterministic entry point that avoids half-initialized onboarding state, fully documented as an intentional architectural decision.
## ADR-010: Usage-Based Bold Typography & Semantic Hierarchy System
- **Date**: 2026-10-22
- **Context**: The user requested bolder, usage-based font styles to enhance typographic hierarchy, visual rhythm, and metric prominence in the web and mobile interfaces.
- **Decision**:
  - Maintained the 9 standard Material `TextTheme` tokens strictly bound to DM Sans.
  - Added dedicated semantic styles to `AppTypography`:
    - `statDisplay`: 28sp, Bold 700, -0.5 tracking for hero metric numbers ("2h 15m", "45m", Level 13).
    - `statLabel`: 12sp, SemiBold 600, 0.2 tracking for metric subtitles ("Today's Listening").
    - `cardTitle`: 18sp, Bold 700 for primary card titles.
    - `sectionHeader`: 20sp, Bold 700 for distinct section divisions ("Quick Access").
    - `labelBold`: 14sp, Bold 700 for item headlines ("Headphones Connected", form labels).
    - `captionBold`: 12sp, SemiBold 600 for status chips and unit badges.
  - Extended `EchoText` with optional `fontWeight`, `fontSize`, and `letterSpacing` overrides for granular contextual control.
  - Preloaded DM Sans (weights 100–1000) in `web/index.html` to guarantee authentic geometric font rendering across Chrome and web canvas renderers.
- **Consequences**: Significantly improved visual scannability and contrast on both desktop viewports and mobile screens without introducing unapproved font families.

## ADR-011: Ambient Atmospheric Soft Tint Backdrop (Part B)
- **Date**: 2026-10-23
- **Context**: The application required an ambient, light-blue atmospheric depth behind screens without competing with foreground text, without adding non-approved colors, and without introducing heavy runtime blur/shader filters behind scrolling content.
- **Decision**:
  - Implemented `EchoBackdrop` with a single static `CustomPainter` inside a `RepaintBoundary` and `ExcludeSemantics`.
  - Painted layers:
    1. Base fill: `AppColors.surface` (`#F4F8FC`).
    2. Radial gradient tints: `backdropTintA` (~45% alpha `blue100`), `backdropTintB` (~35% alpha `blue100`), and `backdropTintCenter` (~25% alpha `blue100`). Gradients fade to `backdropFade` (`Color(0x00E1EEFA)`) instead of black-transparent, preserving pure light-blue tonal interpolation.
    3. Faint acoustic wave motif near bottom in `backdropWave` (`Color(0x1AB9D8F4)`), echoing the sound-wave brand identity.
  - Optional 60s slow drift (< 16dp travel) that fully stops when `MediaQuery.disableAnimations` is active, and is off by default in test suites.
  - Mounted behind the Navigator inside `EchoResponsiveFrame`, with `ThemeData.scaffoldBackgroundColor` set to `AppColors.transparent` so cards, app bars, and bottom nav retain their crisp opaque surfaces.
- **Consequences**: Mathematical verification proves the darkest blended backdrop pixel has luminance $\ge 0.84$, guaranteeing WCAG AA compliance ($\ge 4.5:1$) for `textPrimary` (~13.8:1), `textSecondary` (~4.72:1), and `blue500` (~4.90:1) with zero runtime layout overhead.

## ADR-012: Split Horizon Launch Intro & Cold-Start Gate (Part A)
- **Date**: 2026-10-23
- **Context**: ECHO required a signature branded launch intro ("Split Horizon") communicating acoustic awareness and loading readiness without introducing a route that would perturb the canonical 36-route inventory or redirect logic.
- **Decision**:
  - Implemented `EchoSplashGate` as an overlay widget in `main.dart`'s builder, wrapping the app subtree with `IgnorePointer` and `ExcludeSemantics` while active.
  - Core sequence:
    1. 0.0-0.6s: Top half slides down in `AppColors.blue500` to 50% height while a 2dp `blue400` line draws outward from center.
    2. 0.5-1.2s: Staggered letter reveal (60ms step) with upward slide and fade. Rendered twice and dual-clipped: white letters on top blue half, `blue500` letters on bottom white half.
    3. 1.2-2.0s: Acoustic ghost echoes expand outward into both halves (`splashGhostTop1..3`, `splashGhostBottom1..3`) with scales 1.08, 1.16, 1.24.
    4. 2.0-2.6s: Tagline *"Listen with awareness"* in caption style fades in. Top blue half retracts upward while bottom white half fades out, revealing the app.
  - Lifecycle: Enforces a minimum 1.8s hold, dismisses when initialization resolves, and enforces a 4.0s hard cap. Tap anywhere triggers immediate skip-to-reveal.
  - Accessibility: `MediaQuery.disableAnimations` triggers a static complete frame held for ~800ms before cutting cleanly. Single semantics node (`ECHO, loading`) with `sendAnnouncement('ECHO ready')` upon dismissal.
- **Consequences**: Zero impact on route count, route tables, or redirects. 100% resilient to 200% text scale and 320dp width viewports.



