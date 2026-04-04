<p align="center">
  <img src="Patient/assets/images/icon.png" alt="MedAssist AI" width="120" height="120" />
</p>

<h1 align="center">MedAssist AI</h1>

<p align="center">
  <strong>AI-Powered Healthcare Platform — Patient App + Doctor Portal</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/React-19-61DAFB?logo=react" />
  <img src="https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase" />
  <img src="https://img.shields.io/badge/NVIDIA_NIM-Llama_3.3-76B900?logo=nvidia" />
  <img src="https://img.shields.io/badge/Jitsi_Meet-Video_Calls-97979A?logo=jitsi" />
  <img src="https://img.shields.io/badge/Razorpay-Payments-0C2451?logo=razorpay" />
</p>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Patient App (Flutter)](#-patient-app-flutter)
- [Doctor Portal (React + Vite)](#-doctor-portal-react--vite)
- [Supabase Backend](#-supabase-backend)
- [Edge Functions](#-edge-functions)
- [Database Schema](#-database-schema)
- [Setup & Installation](#-setup--installation)
- [Deployment](#-deployment)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Screenshots](#-screenshots)
- [Environment Variables](#-environment-variables)
- [License](#-license)

---

## Overview

**MedAssist AI** is a full-stack healthcare platform connecting patients with doctors through AI-driven clinical intelligence, real-time video consultations, and comprehensive health monitoring. The system consists of three interconnected components:

| Component | Technology | Description |
|-----------|-----------|-------------|
| **Patient App** | Flutter (Android/iOS/Web) | Mobile-first health management app |
| **Doctor Portal** | React + Vite + Tailwind | Web dashboard for healthcare providers |
| **Backend** | Supabase (PostgreSQL + Edge Functions) | Shared database, auth, and AI pipeline |

### Key Highlights

- 🧠 **AI Clinical Intelligence** — NVIDIA NIM (Llama 3.3 70B) powers symptom triage, medical document analysis, and health trend forecasting
- 🎥 **Telehealth** — End-to-end encrypted Jitsi Meet video consultations between patients and doctors
- 💳 **Payments** — Razorpay integration for appointment booking and consultation fees
- 📊 **Health Connect** — Native Android Health Connect API for real-time vitals monitoring
- 🔐 **Security** — Row-Level Security (RLS) on all tables, Supabase Auth with OAuth providers

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SUPABASE (PostgreSQL)                        │
│  ┌─────────────┐ ┌──────────────┐ ┌────────────┐ ┌──────────────┐  │
│  │   patients   │ │doctor_profiles│ │  bookings  │ │  ai_results  │  │
│  │   profiles   │ │  doctors_live │ │  referrals │ │ health_memory│  │
│  └──────┬───────┘ └──────┬───────┘ └─────┬──────┘ └──────┬───────┘  │
│         │                │               │               │          │
│  ┌──────┴────────────────┴───────────────┴───────────────┴───────┐  │
│  │              Supabase Edge Functions (Deno)                   │  │
│  │  • symptom-triage  • analyze-medical-record                   │  │
│  │  • analyze-health-trends  • compare-medical-reports           │  │
│  └───────────────────┬───────────────────────────────────────────┘  │
│                      │ NVIDIA NIM API                               │
│                      ▼                                              │
│              ┌───────────────┐                                      │
│              │ Llama 3.3 70B │                                      │
│              │   Gemma 3 27B │                                      │
│              └───────────────┘                                      │
└─────────────────────────────────────────────────────────────────────┘
         │                                    │
         ▼                                    ▼
┌─────────────────┐               ┌─────────────────────┐
│  PATIENT APP    │               │   DOCTOR PORTAL      │
│  Flutter        │◄─── Jitsi ───►│   React + Vite       │
│  Android/iOS    │    Meet SDK   │   Vercel Hosted       │
│  Web (Chrome)   │               │                       │
│                 │               │  • Dashboard           │
│  • Symptom Chat │               │  • Patient Records     │
│  • Body Map     │               │  • Live Bookings       │
│  • Health Dash  │               │  • Consultation Room   │
│  • Doctor Finder│               │  • Analytics           │
│  • Nutrition    │               │  • AI Assistant        │
│  • Recovery     │               │  • Schedule Manager    │
│  • Video Calls  │               │  • Profile Setup       │
└─────────────────┘               └───────────────────────┘
```

---

## 📱 Patient App (Flutter)

The patient-facing mobile application built with Flutter, supporting Android, iOS, and Web.

### Feature Modules

| Module | Directory | Description |
|--------|-----------|-------------|
| **Symptom Chat** | `features/symptom_chat/` | AI-powered symptom analysis with conversational UI. Sends symptoms to the `symptom-triage` edge function powered by Llama 3.3 70B |
| **Body Map** | `features/body_map/` | Interactive SVG body diagram for precise pain/symptom location mapping |
| **Health Dashboard** | `features/health/` | Real-time vitals from Android Health Connect — steps, heart rate, blood pressure, SpO2, sleep, calories |
| **Recovery Monitoring** | `features/monitoring/` | AI-computed recovery score (0-100) based on vitals, symptoms, and medication adherence with animated ring chart |
| **Doctor Discovery** | `features/doctors/` | Browse verified doctors from `doctors_live` view, filter by specialty, view fees/availability |
| **Doctor Detail** | `features/doctors/` | Premium detail screen with hero banner, animated stat chips, slot picker, and booking CTA |
| **Video Consultation** | `features/consultation/` | Jitsi Meet SDK (native) / iframe (web) for E2E encrypted video calls with doctors |
| **Nutrition Tracker** | `features/nutrition/` | Calorie/macro tracking with food search, meal logging, and daily nutrition ring charts |
| **Medical Records** | `features/records/` | Upload, view, and AI-analyze medical documents (PDFs, images) via Gemma 3 vision model |
| **Deep Check** | `features/deep_check/` | Comprehensive health analysis comparing multiple reports over time |
| **SOS Emergency** | `features/sos/` | One-tap emergency alerts with GPS location sharing to family contacts |
| **Nearby Hospitals** | `features/hospitals/` | Map-based hospital/pharmacy finder using OpenStreetMap + Geolocator |
| **Pharmacy** | `features/pharmacy/` | Nearby pharmacy search and medication availability |
| **Profile & Settings** | `features/profile/` | iOS-style settings with dark mode, notification preferences, privacy controls |
| **Onboarding** | `features/onboarding/` | First-launch onboarding flow with feature highlights |

### Core Architecture

```
lib/
├── core/
│   ├── ai/              # AI service layer (NVIDIA NIM client)
│   ├── payments/         # Razorpay payment service
│   ├── repositories/     # Data access layer (Supabase queries)
│   ├── router/           # GoRouter navigation config
│   ├── services/         # Business logic services
│   ├── state/            # Global state management
│   ├── theme/            # AppColors, typography, design tokens
│   ├── widgets/          # Shared reusable widgets
│   └── utils/            # Helpers, formatters, validators
├── features/             # Feature-specific modules (see table above)
└── main.dart             # App entry point
```

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^3.3.1 | State management |
| `go_router` | ^17.1.0 | Declarative routing |
| `supabase_flutter` | ^2.12.2 | Backend client |
| `jitsi_meet_flutter_sdk` | ^11.6.0 | Video consultations |
| `razorpay_flutter` | ^1.3.7 | Payment processing |
| `health` | ^13.3.1 | Android Health Connect |
| `fl_chart` | ^1.2.0 | Charts and graphs |
| `speech_to_text` | ^7.3.0 | Voice input for symptoms |
| `mobile_scanner` | ^7.2.0 | QR code scanning |
| `flutter_map` | ^8.2.2 | OpenStreetMap integration |
| `google_fonts` | ^8.0.2 | Inter, Outfit typography |
| `permission_handler` | ^12.0.1 | Runtime permissions |

---

## 🩺 Doctor Portal (React + Vite)

A modern web dashboard for healthcare professionals, deployed on Vercel.

### Pages

| Page | File | Description |
|------|------|-------------|
| **Login** | `Login.tsx` | Email/password + Google/Apple OAuth |
| **Signup** | `Signup.tsx` | Doctor registration with specialization selection, auto-creates `doctor_profiles` row |
| **Dashboard** | `Dashboard.tsx` | Overview — today's appointments, patient count, revenue charts, recent activity feed |
| **Profile Setup** | `DoctorProfileSetup.tsx` | 7-tab wizard: Overview, Workplaces, Availability, Fees, Reviews, Documents, Settings |
| **Patients** | `Patients.tsx` | Full patient list with search, filters, and health history drawer |
| **Patient Record** | `PatientRecordPage.tsx` | Detailed patient medical card with vitals timeline, diagnoses, medications |
| **Today's Appointments** | `TodayAppointments.tsx` | Today's schedule with status tracking |
| **Live Bookings** | `LiveBookings.tsx` | Real-time booking feed from patient app |
| **Consultation Room** | `ConsultationRoom.tsx` | 3-panel layout: QR Passport • Jitsi Video • AI Insights |
| **Schedule** | `Schedule.tsx` | Full weekly/monthly calendar with slot management |
| **Analytics** | `Analytics.tsx` | Revenue, patient demographics, consultation trends with Recharts |
| **AI Assistant** | `AIAssistant.tsx` | Chat-based AI for clinical decision support |
| **Prescription Writer** | `PrescriptionWriter.tsx` | Digital prescription authoring tool |
| **Emergency Alerts** | `EmergencyAlerts.tsx` | SOS alerts from patients |
| **Scan Page** | `ScanPage.tsx` | QR code scanner for patient verification |
| **Patient Case Flow** | `PatientCaseFlow.tsx` | End-to-end case management workflow |

### Services

| Service | Description |
|---------|-------------|
| `authService.ts` | Supabase Auth (signup auto-creates `doctor_profiles`) |
| `doctorProfileService.ts` | CRUD for doctor profile + completion % calculation |
| `bookingService.ts` | Booking management + patient profile lookup |
| `consultationService.ts` | Consultation intelligence + AI analysis |
| `analyticsService.ts` | Revenue/patient analytics queries |
| `scheduleService.ts` | Availability and slot management |
| `medcardService.ts` | Patient medical card data |
| `aiChatService.ts` | AI chat for clinical assistance |
| `profileService.ts` | Doctor profile data |

---

## ☁️ Supabase Backend

All data lives in a shared Supabase PostgreSQL instance. Both the patient app and doctor portal connect to the same project.

### Auth Configuration

- **Email/Password** — Primary auth method
- **Google OAuth** — Enabled for both portals
- **Apple OAuth** — Doctor portal only
- **RLS** — Row-Level Security on all tables
- **JWT** — Supabase handles token refresh automatically

### Storage Buckets

| Bucket | Purpose |
|--------|---------|
| `medical-documents` | Patient medical records (PDFs, images) |
| `doctor-documents` | Doctor verification documents (licenses, degrees) |
| `profile-photos` | Doctor and patient profile images |

---

## ⚡ Edge Functions

Serverless Deno functions hosted on Supabase, calling NVIDIA NIM APIs for clinical intelligence.

### `symptom-triage`
**Purpose:** AI-powered symptom analysis and clinical triage  
**Model:** NVIDIA NIM — Llama 3.3 70B Instruct  
**Input:** Patient symptoms, medical history, vitals  
**Output:** Risk score, possible conditions, urgency level, recommended actions, doctor handoff

### `analyze-medical-record`
**Purpose:** Medical document intelligence (OCR + clinical extraction)  
**Model:** NVIDIA NIM — Gemma 3 27B (Vision)  
**Input:** Medical document image/PDF  
**Output:** Structured clinical data — diagnoses, medications, lab values, recommendations

### `analyze-health-trends`
**Purpose:** Longitudinal health trend analysis  
**Model:** NVIDIA NIM — Llama 3.3 70B Instruct  
**Input:** Historical vitals, lab results, medications  
**Output:** Trend analysis, risk forecasting, lifestyle recommendations

### `compare-medical-reports`
**Purpose:** Multi-report comparison and delta analysis  
**Model:** NVIDIA NIM — Llama 3.3 70B Instruct  
**Input:** Two or more medical reports  
**Output:** Improvements/deteriorations, key changes, clinical significance

---

## 🗃️ Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `profiles` | Patient user profiles (linked to Supabase Auth) |
| `doctor_profiles` | Doctor profiles with JSONB fields: overview, workplaces, availability, fees, documents, settings |
| `bookings` | Appointment bookings with Razorpay order IDs and Jitsi room IDs |
| `ai_results` | AI triage results with conditions, risk scores, and doctor handoff data |
| `doctor_handoffs` | AI-generated referrals from triage to specific specialties |
| `health_memory` | Patient's AI health memory — conditions, medications, allergies |
| `medical_records` | Uploaded medical documents with AI analysis results |
| `referrals` | Doctor-to-specialist referral chain |
| `sos_alerts` | Emergency alerts with GPS coordinates |

### Views

| View | Description |
|------|-------------|
| `doctors_live` | Patient-facing view of `doctor_profiles` — exposes name, specialty, experience, fees (video + in-person), bio, photo, verification status, available slots |

### Key SQL Files

| File | Purpose |
|------|---------|
| `schema.sql` | Base schema with seed data |
| `universal_cross_portal_schema.sql` | Cross-portal tables (bookings, AI results, health memory) |
| `supabase_doctor_profiles.sql` | Doctor profiles table with JSONB fields |
| `supabase_rls_doctors_fix.sql` | RLS policies + `doctors_live` view creation |
| `universal_vault_schema.sql` | Health vault and document storage schema |

---

## 🚀 Setup & Installation

### Prerequisites

- **Flutter** ≥ 3.11.4
- **Node.js** ≥ 18
- **Supabase** account (free tier works)
- **NVIDIA NIM** API key (for AI features)
- **Razorpay** test keys (for payments)

### 1. Clone the Repository

```bash
git clone https://github.com/ADG1411/MedAssist-AI.git
cd MedAssist-AI
```

### 2. Patient App Setup

```bash
cd Patient

# Create environment file
cp .env.example .env
# Edit .env with your Supabase URL, anon key, and NVIDIA NIM key

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### 3. Doctor Portal Setup

```bash
cd doctorportel/frontend

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your Supabase URL and anon key

# Run development server
npm run dev

# Build for production
npm run build
```

### 4. Database Setup

Run these SQL files in your Supabase SQL Editor, **in order**:

1. `schema.sql` — Base tables + seed data
2. `universal_cross_portal_schema.sql` — Cross-portal tables
3. `supabase_doctor_profiles.sql` — Doctor profiles
4. `supabase_rls_doctors_fix.sql` — RLS policies + doctors_live view

### 5. Edge Functions

```bash
# Deploy edge functions to Supabase
supabase functions deploy symptom-triage
supabase functions deploy analyze-medical-record
supabase functions deploy analyze-health-trends
supabase functions deploy compare-medical-reports
```

---

## 🌐 Deployment

### Patient App
- **Android:** `flutter build apk --release` → distribute APK
- **iOS:** `flutter build ipa` → upload to App Store Connect
- **Web:** `flutter build web` → deploy to any static host

### Doctor Portal
- **Platform:** Vercel
- **Config:** `vercel.json` with SPA rewrites
- **Build:** `tsc --noEmit && vite build`
- **Output:** `dist/`

```bash
# Deploy to Vercel
cd doctorportel/frontend
npx vercel --prod
```

### Environment Variables (Vercel)

| Variable | Value |
|----------|-------|
| `VITE_SUPABASE_URL` | Your Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase anon/public key |

---

## 🛠️ Tech Stack

### Frontend
| Technology | Usage |
|-----------|-------|
| **Flutter 3.11+** | Patient app (Android, iOS, Web) |
| **Dart** | Patient app language |
| **React 19** | Doctor portal |
| **TypeScript** | Doctor portal language |
| **Vite 8** | Doctor portal build tool |
| **Tailwind CSS 3** | Doctor portal styling |
| **Framer Motion** | Doctor portal animations |
| **Recharts** | Doctor portal analytics charts |

### Backend
| Technology | Usage |
|-----------|-------|
| **Supabase** | PostgreSQL database, Auth, Storage, Edge Functions |
| **Deno** | Edge function runtime |
| **NVIDIA NIM** | AI model inference (Llama 3.3 70B, Gemma 3 27B) |

### Integrations
| Service | Usage |
|---------|-------|
| **Jitsi Meet** | End-to-end encrypted video consultations |
| **Razorpay** | Payment processing (INR) |
| **Android Health Connect** | Vitals data (steps, heart rate, SpO2, sleep) |
| **OpenStreetMap** | Hospital/pharmacy map |
| **Google Fonts** | Typography (Inter, Outfit) |

---

## 📁 Project Structure

```
MedAssist-AI/
├── Patient/                          # Flutter patient app
│   ├── android/                      # Android platform config
│   │   ├── app/
│   │   │   ├── build.gradle.kts      # Android build config (minSdk 26)
│   │   │   ├── proguard-rules.pro    # Jitsi + Razorpay + Health Connect
│   │   │   └── src/main/
│   │   │       └── AndroidManifest.xml  # Permissions (Camera, Mic, Health)
│   │   └── build.gradle.kts          # Project-level Gradle
│   ├── lib/
│   │   ├── core/                     # Shared architecture
│   │   │   ├── ai/                   # NVIDIA NIM client
│   │   │   ├── payments/             # Razorpay service
│   │   │   ├── repositories/         # Data layer
│   │   │   ├── router/               # GoRouter config
│   │   │   ├── services/             # Business logic
│   │   │   ├── theme/                # Design tokens
│   │   │   └── widgets/              # Reusable components
│   │   ├── features/                 # Feature modules
│   │   │   ├── auth/                 # Login, signup, onboarding
│   │   │   ├── symptom_chat/         # AI symptom triage
│   │   │   ├── body_map/             # Interactive body diagram
│   │   │   ├── health/               # Health Connect dashboard
│   │   │   ├── monitoring/           # Recovery score
│   │   │   ├── doctors/              # Doctor discovery + booking
│   │   │   ├── consultation/         # Jitsi video calls
│   │   │   ├── nutrition/            # Calorie tracking
│   │   │   ├── records/              # Medical documents
│   │   │   ├── deep_check/           # Multi-report analysis
│   │   │   ├── hospitals/            # Nearby hospitals map
│   │   │   ├── pharmacy/             # Pharmacy finder
│   │   │   ├── sos/                  # Emergency alerts
│   │   │   └── profile/              # Settings
│   │   └── main.dart
│   └── pubspec.yaml
│
├── doctorportel/                     # Doctor portal
│   └── frontend/
│       ├── src/
│       │   ├── pages/                # Route pages (18 pages)
│       │   ├── components/           # React components
│       │   ├── services/             # API services
│       │   ├── layouts/              # Dashboard layout
│       │   ├── lib/                  # Supabase client
│       │   └── types/                # TypeScript types
│       ├── vercel.json               # Vercel deployment config
│       ├── vite.config.ts            # Vite build config
│       └── package.json
│
├── supabase/
│   └── functions/                    # Edge functions
│       ├── analyze-health-trends/    # Health trend AI
│       ├── analyze-medical-record/   # Document OCR + analysis
│       └── compare-medical-reports/  # Report comparison
│
├── schema.sql                        # Base database schema
├── universal_cross_portal_schema.sql # Cross-portal tables
├── supabase_doctor_profiles.sql      # Doctor profiles schema
└── supabase_rls_doctors_fix.sql      # RLS + doctors_live view
```

---

## 🔑 Environment Variables

### Patient App (`.env`)

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
NVIDIA_NIM_API_KEY=your-nvidia-nim-key
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=your-secret
```

### Doctor Portal (`.env`)

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

---

## 📸 Screenshots

> See the app in action by running `flutter run -d chrome` for the patient app and `npm run dev` for the doctor portal.

---

## 👤 Author

**ADG1411** — [GitHub](https://github.com/ADG1411)

---

## 📄 License

This project is proprietary. All rights reserved.
