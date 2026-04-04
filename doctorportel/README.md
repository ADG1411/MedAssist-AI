# MedAssist-AI: Doctor Portal 🩺🚀

![React Native](https://img.shields.io/badge/React_Native-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Expo](https://img.shields.io/badge/expo-1C1E24?style=for-the-badge&logo=expo&logoColor=#D04A37)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![NVIDIA NIM](https://img.shields.io/badge/NVIDIA_NIM-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/tailwindcss-%2338B2AC.svg?style=for-the-badge&logo=tailwind-css&logoColor=white)

The **Doctor Portal** is the provider-facing module of the MedAssist-AI ecosystem. Built with an enterprise-grade Expo/React Native UI, it acts as a comprehensive, AI-enhanced clinical operating system designed to streamline day-to-day medical workflows, patient monitoring, and predictive clinical analysis.

## ✨ Core Features

### 1. 🛡️ Secure QR Patient Access (Scanner)
Goodbye to manual entry. Doctors can securely initiate temporary or permanent, encrypted Row-Level-Security (RLS) database access by scanning a patient's unique `MEDCARD::` QR Code. Instantly unarchives a secure pipeline bridging the Patient's App directly into the Doctor's dashboard.

### 2. 🤖 Strict AI Co-Pilot & Clinical Analysis
Powered by NVIDIA NIM (`stepfun-ai/step-3.5-flash`), the internal AI Co-Pilot acts as a powerful clinical assistant.
- **2-Step AI Guard System**: Utilitizes a strict LLM-based architectural classifier that auto-rejects non-medical prompts (temperature: `0.1`). Valid prompts are passed to the heavy analytic engine.
- **Context Injection**: The AI silently hooks into live Supabase records. It inherently "knows" a doctor's daily booking load, active patient demographics, and active case histories.
- **Decision Support**: Capable of evaluating risk factors, warning against drug-interactions, and proposing evidence-based differential bounds.

### 3. 📂 Intelligent Case Workflow Manager
Automatically aggregates all active patients the doctor possesses access rights to. Replaces outdated spreadsheets with live "Case Cards" dynamically computing:
- The patient's most recent AI-determined Risk Severity.
- Active symptoms or primary diagnosis.
- Last-visited timestamps auto-calculated via live table joins.

### 4. 🫀 Patient Dashboard & Medical Records
A beautifully streamlined viewport displaying chronological medical records, recent vital signs (HR, BP, SpO2), underlying chronic conditions, and flagged allergies. Highlights emergency metrics via adaptive, blood-type specific gradient UI components.

### 5. 🎟️ Referral & Prescription Generation
Seamless referral routing UI. After creating a prescription or diagnostic lab recommendation, the system pushes a verifiable `REFQR::` token back to the patient.

### 6. ⚙️ Web/Mobile Cross-Platform Operation
Constructed flawlessly using standard React Native Web & Expo paradigms. Designed to accommodate browser CORS restrictions via silent localized proxies, maintaining pure functionality regardless of whether the doctor is utilizing an iOS tablet, Android phone, or Web Desktop interface.

---

## 🛠️ Architecture & Tech Stack

* **Frontend Framework:** Expo (React Native & React Native Web)
* **Styling Engine:** TailwindCSS (via NativeWind/Custom Theme Variables)
* **Backend BaaS:** Supabase (PostgreSQL, Supabase Auth, Row Level Security)
* **AI Provider:** NVIDIA NIM Cloud API 

### Database Schema Structure (Highlight)
- `doctor_profiles` & `doctor_stats`: Handles credential visualization.
- `doctor_patient_access`: The bridge mapping a secure connection between Provider & Patient IDs.
- `ai_results`: Live analytical risk factors parsed into the Case Module.
- `bookings`: Scheduling synchronization architecture.

---

## 🚀 Local Development Setup

Follow these steps to run the Doctor Portal locally:

### 1. Pre-requisites
Ensure you have the following installed:
- [Node.js](https://nodejs.org/) (v18+)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (optional, if running backend locally)
- Expo Go (for mobile testing) or a configured Simulator

### 2. Installation
Navigate to the `doctorportel/expo-app` directory and install the required modules:
\`\`\`bash
cd doctorportel/expo-app
npm install
\`\`\`

### 3. Environment Variables
Add your Supabase endpoint and NVIDIA API keys to the root environment or replace them securely in your constants file where necessary.

### 4. Starting the Server
To initialize the development server (optimized for Web deployment):
\`\`\`bash
npx expo start --web --clear
\`\`\`
*To run dynamically on a physical device, scan the generated Metro Bundler QR Code using the Expo Go Application.*

---

## 🤝 Project Ecosystem Integration

The **Doctor Portal** directly communicates with the unified **MedAssist-AI Supabase Backend** and reads constraints dictated by the **Patient App** module. Modifying the `universal_cross_portal_schema.sql` will impact RLS policies cascading across all adjacent ecosystem modules.
