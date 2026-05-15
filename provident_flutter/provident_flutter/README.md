# Provident – Flutter App

AI Smile Analysis Assistant — Flutter port of the React/Next.js project.

## Project Structure

```
lib/
├── main.dart                          # Entry point, MultiProvider setup
├── providers/
│   ├── app_provider.dart              # Main state management (Provider)
│   └── chat_provider.dart             # Chat/assistant state
├── utils/
│   └── app_theme.dart                 # Colors, gradients, ThemeData
├── widgets/                           # Reusable UI components
│   ├── app_header.dart                # Gradient header with back button
│   ├── bottom_nav.dart                # Tab bar + chat input bar
│   ├── floating_message.dart          # Smiley message bubble above nav
│   ├── layout_wrapper.dart            # Full-screen layout shell
│   └── primary_button.dart            # Gradient CTA button
└── views/screens/
    ├── analysis_flow_screen.dart      # Root orchestrator (step router)
    ├── sign_in_screen.dart            # Login + social buttons
    ├── patient_registration_screen.dart  # Patient form
    ├── analyze_start_screen.dart      # Smile graphic + upload options
    ├── upload_screen.dart             # Photo preview + tips
    ├── question_screen.dart           # Yes/No questionnaire
    ├── report_screen.dart             # Provisional analysis report
    ├── assistant_screen.dart          # AI dentist chat
    └── reports_screen.dart            # Past reports list
```

## State Management

**Provider** was chosen because:
- The app state is straightforward (a single linear flow)
- `AppProvider` tracks the current step, active tab, patient data, and question answers
- `ChatProvider` is scoped locally to `AssistantScreen` via `ChangeNotifierProvider`
- No complex async state or server sync needed at this stage

## Prerequisites

1. Flutter SDK ≥ 3.0.0 — https://flutter.dev/docs/get-started/install
2. Dart SDK ≥ 3.0.0 (bundled with Flutter)
3. Android Studio / Xcode for device/emulator

## Setup & Run

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on connected device or emulator
flutter run

# 3. Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome        # Web support
flutter run -d macos         # Desktop (macOS)

# 4. Build release APK
flutter build apk --release

# 5. Build iOS release
flutter build ios --release
```

## Features Implemented

| React Component | Flutter Equivalent |
|---|---|
| `ThemeProvider` + `theme-presets.ts` | `AppTheme` + `AppColors` constants |
| `AnalysisFlow` state machine | `AppProvider` with `AppStep` enum |
| `LayoutWrapper` | `LayoutWrapper` widget |
| `Header` | `AppHeader` widget |
| `BottomNav` + `ChatBar` | `AppBottomNav` widget |
| `FloatingMessage` | `FloatingMessage` widget |
| `SignInScreen` | `SignInScreen` |
| `PatientRegistration` | `PatientRegistrationScreen` with `Form` + validation |
| `AnalyzeStartScreen` + SVG smile | `AnalyzeStartScreen` + `CustomPainter` |
| `UploadScreen` | `UploadScreen` with `Image.network` |
| `QuestionScreen` | `QuestionScreen` with `LinearProgressIndicator` |
| `ReportScreen` | `ReportScreen` with animated progress bars |
| `AssistantScreen` | `AssistantScreen` with chat bubbles + typing indicator |
| `ReportsScreen` | `ReportsScreen` |
| `framer-motion` animations | Flutter `AnimationController` / `AnimatedBuilder` |
| CSS gradients | Flutter `LinearGradient` + `BoxDecoration` |

## Design Fidelity

- All color values (#2E6DD1, #1D4ED8, #3A5D84, etc.) matched exactly
- Border radius, shadows, padding replicated from Tailwind classes
- Gradient buttons, floating message bubble, header blur circles
- Smile custom SVG → `CustomPainter`
- Typing indicator with bouncing dots animation
- Progress bar in questions screen
- Report cards with colored status indicators
