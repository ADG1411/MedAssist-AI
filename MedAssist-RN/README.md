# MedAssist AI — React Native + Expo

A full React Native + Expo conversion of the MedAssist Flutter application. Premium medical assistant with AI-powered symptom analysis, nutrition coaching, recovery tracking, and doctor consultations.

## Tech Stack

- **Framework:** React Native 0.81 + Expo SDK 54
- **Navigation:** Expo Router (file-based)
- **State:** Zustand
- **Backend:** Supabase (auth, DB, edge functions)
- **Animations:** React Native Reanimated 4
- **UI:** expo-blur (glassmorphism), expo-linear-gradient, react-native-svg
- **Fonts:** Inter (via @expo-google-fonts)
- **Icons:** @expo/vector-icons (Ionicons)

## Getting Started

```bash
# Install dependencies
npm install

# Create .env from template
cp .env.example .env
# Fill in your Supabase URL and anon key

# Start development server
npx expo start
```

## Project Structure

```
MedAssist-RN/
├── app/                          # Expo Router pages
│   ├── _layout.tsx               # Root layout (Stack)
│   ├── index.tsx                 # Splash screen
│   ├── onboarding.tsx            # Onboarding carousel
│   ├── login.tsx                 # Login screen
│   ├── signup.tsx                # Signup screen
│   ├── (tabs)/                   # Bottom tab navigator
│   │   ├── _layout.tsx           # Tab bar + SOS FAB
│   │   ├── home.tsx              # Dashboard (9 widgets)
│   │   ├── doctors.tsx           # Doctor explorer
│   │   ├── nutrition.tsx         # Nutrition diary
│   │   ├── records.tsx           # Health records
│   │   └── profile.tsx           # Profile & settings
│   ├── symptom-check.tsx         # Body map + symptom input
│   ├── symptom-chat.tsx          # AI symptom triage chat
│   ├── ai-result.tsx             # AI diagnosis result
│   ├── deep-check.tsx            # Deep analysis follow-up
│   ├── doctor-detail.tsx         # Doctor profile & booking
│   ├── consultation.tsx          # Video consultation
│   ├── post-consult.tsx          # Post-consultation summary
│   ├── nutrition-search.tsx      # Food search
│   ├── nutrition-ai.tsx          # AI nutrition coach chat
│   ├── nutrition-barcode.tsx     # Barcode scanner
│   ├── nutrition-image-scan.tsx  # Photo meal analysis
│   ├── nutrition-history.tsx     # Nutrition history
│   ├── food-detail.tsx           # Food nutrition detail
│   ├── activity-search.tsx       # Activity logging
│   ├── monitoring.tsx            # Daily health monitoring
│   ├── recovery-report.tsx       # Recovery analytics
│   ├── daily-followup.tsx        # Daily AI check-in
│   ├── medassist-card.tsx        # Digital health ID card
│   ├── pharmacy.tsx              # Medicine ordering
│   ├── hospitals.tsx             # Nearby hospitals
│   ├── health-connect.tsx        # Wearable connections
│   ├── health-detail.tsx         # Vital detail view
│   └── sos.tsx                   # Emergency SOS
├── src/
│   ├── core/
│   │   ├── theme/                # Colors, useTheme hook
│   │   ├── supabase/             # Supabase client
│   │   ├── cache/                # AsyncStorage cache service
│   │   ├── store/                # Auth Zustand store
│   │   └── services/             # Edge function service
│   ├── features/
│   │   └── dashboard/
│   │       ├── store/            # Dashboard Zustand store
│   │       └── widgets/          # 9 premium dashboard widgets
│   └── shared/
│       └── components/           # GlassCard, AppBackground, ShimmerBox, etc.
├── app.json                      # Expo config
├── tsconfig.json                 # TypeScript config
├── package.json                  # Dependencies
└── .env.example                  # Environment template
```

## Features (40+ screens)

| Module | Screens |
|--------|---------|
| **Auth** | Splash, Onboarding, Login, Signup |
| **Dashboard** | 9 premium widgets: Header, Health Score, Attention Hub, Live Vitals, AI Insights, Quick Actions, Recovery Mission, Daily Care Engine, Health Timeline |
| **Symptom AI** | Body Map, AI Chat, Diagnosis Result, Deep Analysis |
| **Nutrition** | Diary, Search, Food Detail, AI Coach, Barcode Scanner, Photo Scan, History, Activity Log |
| **Doctors** | Explorer, Detail/Booking, Video Consultation, Post-Consult Summary |
| **Records** | Health Records vault, MedAssist Health ID Card |
| **Monitoring** | Daily Log, Recovery Report, Daily AI Check-in |
| **Services** | Pharmacy, Hospitals, Health Connect (wearables) |
| **Emergency** | SOS with emergency contacts |
| **Profile** | Settings, Theme toggle, Sign out |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `EXPO_PUBLIC_SUPABASE_URL` | Your Supabase project URL |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Your Supabase anonymous key |

## Backend

This app connects to the same Supabase backend as the Flutter version, including:
- **Auth:** Email/password authentication with session persistence
- **Database:** profiles, monitoring_logs, ai_clinical_context, medication_schedules, appointments
- **Edge Functions:** `symptom-triage`, `nutrition-ai`

## Notes

- The app uses mock/fallback data when Supabase is unavailable
- Camera features (barcode, photo scan) require a native build (not Expo Go)
- Wearable integration (Health Connect) is a UI placeholder — native APIs require EAS build
