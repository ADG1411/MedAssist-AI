I'll create a comprehensive, phase-wise instruction guide for building this Flutter app. Let me structure this properly.Now here's the complete phase-wise prompt guide you can feed directly to your IDE/AI assistant, phase by phase:

---

## Phase 1 — Foundation

```
You are a senior Flutter architect. Build the complete project foundation for a healthcare app called MedAssist AI. Do NOT build any screens yet.

TASKS:
1. pubspec.yaml — add these dependencies:
   flutter_riverpod, go_router, fl_chart, flutter_svg, qr_flutter,
   google_fonts, shimmer, animations, speech_to_text, mobile_scanner

2. main.dart — ProviderScope root, GoRouter initialization, MaterialApp.router with AppTheme

3. core/theme/app_colors.dart — define:
   primary #2A7FFF, softBlue #EAF3FF, success #2ECC71,
   warning #F59E0B, danger #EF4444, surface white, radius 24.0

4. core/theme/app_theme.dart — Material 3 ThemeData using Inter from google_fonts,
   card theme with radius 24, elevated button theme, input decoration theme

5. core/constants/app_constants.dart — strings, asset paths, mock delays

6. core/router/app_router.dart — GoRouter with named routes for ALL 22 screens
   (use stub screens returning Scaffold+Text for now)

7. core/mock/ — create 6 files with realistic data:
   user_mock.dart, chat_mock.dart, nutrition_mock.dart,
   tickets_mock.dart, records_mock.dart, doctors_mock.dart

8. shared/widgets/base_screen.dart — reusable scaffold wrapper with safe area + padding

9. core/state/app_state.dart
   - global app preferences:
     first launch
     selected AI mode
     theme mode
     active ticket id
     last selected body part
   - add restoration-ready structure for future backend plug-in

10. core/theme/theme_notifier.dart
   - Riverpod StateNotifier
   - light / dark / system

11. shared/dialogs/app_bottom_sheet.dart
   - reusable bottom sheet system
   - use for biometric, AI explain, nutrition result, reminder picker, success sheet

12. shared/widgets/app_chart_card.dart
   - reusable chart wrapper for fl_chart sections
   - use for recovery trend, AI comparison, food correlation

13. shared/widgets/app_empty_list.dart
   - reusable compact empty list placeholder
   - icon + title + subtitle + CTA
   - use for no tickets, no records, no medicines, no doctors found

14. core/utils/mock_delay.dart
   - central mock delay utility for async simulation
   - create: Future<void> simulateDelay([int ms = 800])

15. shared/widgets/app_section_card.dart
   - reusable section container: white card, radius 24, shadow, padding
   - use across dashboard, nutrition, ticket detail, and records

Use Dart null safety. Keep code clean and scalable for future backend plug-and-play.
Output all files completely.
```

---

## Phase 2 — Entry Flow

```
Continue building MedAssist AI Flutter app. Foundation from Phase 1 is complete.
Now build the entry flow screens.

SCREENS TO BUILD:

1. features/splash/splash_screen.dart
   - MedAssist logo centered
   - ECG heartbeat: CustomPainter that animates a Path drawing left to right
   - "Loading your health data..." text with opacity animation
   - After 2500ms: navigate to /onboarding if first launch, else /home

2. features/onboarding/onboarding_screen.dart
   - PageView with 3 pages (OnboardingPage widget)
   - Page 1: AI Health Assistant — brain/AI icon, headline, subtitle
   - Page 2: Nutrition Intelligence — food/leaf icon
   - Page 3: Recovery Monitoring — chart/shield icon
   - AnimatedDotIndicator widget at bottom
   - "Get Started" FilledButton on last page → navigate /login
   - "Skip" TextButton top right

3. features/auth/login_screen.dart
   - Tab switcher: Phone | Email
   - Phone tab: country code dropdown + phone TextField (AppTextField)
   - Email tab: email + password fields
   - "Send OTP" / "Login" primary button
   - Biometric icon button → show ModalBottomSheet "Biometric coming soon"

4. features/auth/otp_screen.dart
   - "Enter the 6-digit code sent to +91 98765 43210"
   - 6 individual TextFields auto-advancing (OtpInputWidget)
   - Resend OTP timer countdown 60s
   - Verify button → navigate /home
   - AuthProvider (Riverpod StateNotifier) storing mock auth state

SHARED WIDGETS TO BUILD:
- shared/widgets/app_text_field.dart — styled text input
- shared/widgets/app_button.dart — primary / secondary / ghost variants
- shared/widgets/otp_input.dart — 6-box OTP widget
- shared/widgets/page_dot_indicator.dart

Output all files completely with full working code.
```

---

## Phase 3 — Home Dashboard

```
Continue MedAssist AI Flutter app. Phases 1 and 2 complete.
Build the Home Dashboard and persistent bottom navigation shell.

1. shared/navigation/scaffold_with_bottom_nav.dart
   - Persistent BottomNavigationBar: Home, Tickets, Nutrition, Records, Profile
   - GoRouter ShellRoute so tab state persists
   - Floating SOS button overlay (red, positioned bottom-right)

2. features/dashboard/home_screen.dart
   - Greeting card: "Good morning, [Name] 👋" + date
   - HealthScoreRing: AnimatedCircularRing CustomPainter, score animates 0→78
   - Quick Action Grid (2×2): Start Symptom Check / Nutrition / My Tickets / Emergency SOS
   - Active Monitoring Card: collapsible, shows Day 3/5 with progress bar
   - Recent AI Result card: condition name, confidence %, risk chip, "View Details" link
   - Medicine Reminder card: medicine name, time, Snooze + Take buttons
   - "How are you feeling today?" — 5 mood emoji buttons (😢😕😐🙂😄)
   - Shimmer skeleton loader shown for 800ms then fades to real content

PROVIDERS:
   - DashboardProvider (StateNotifier): loads mock data with 800ms delay, exposes loading state
   - AuthProvider: provides current user from user_mock.dart

SHARED WIDGETS:
   - shared/widgets/health_score_ring.dart — CustomPainter circular progress
   - shared/widgets/quick_action_card.dart — icon + label + color
   - shared/widgets/shimmer_box.dart — shimmer placeholder
   - shared/widgets/section_header.dart — title + optional "See All" link
   - shared/widgets/status_chip.dart — colored rounded chip

All animations must use AnimationController with proper dispose.
Output all files completely.
```

---

## Phase 4 — AI Symptom Flow

```
Continue MedAssist AI Flutter app. Phases 1–3 complete.
Build the complete AI symptom checking flow.

1. features/body_map/body_map_screen.dart
   - Toggle bar: Front | Back view
   - SVG human body (use flutter_svg with a simple SVG string or asset)
   - 7 tappable regions: Head, Chest, Stomach, Back, Arms, Legs, Full Body
   - Selected region: AnimatedContainer with blue glow border + scale pulse
   - Symptom type chips (multi-select): Mild / Moderate / Severe / Burning / Sharp / Dull / Throbbing
   - "Continue" button → /symptom-chat, disabled until region + symptom selected
   - SymptomCheckProvider stores selections

2. features/symptom_chat/symptom_chat_screen.dart
   - AppBar with progress stepper (Step 2/4) + AI mode badge (Fast AI / Deep Check toggle)
   - ChatListView: ListView.builder with reverse:true
   - UserBubble: blue bubble right-aligned
   - AIBubble: white card left-aligned, with MedAssist avatar
   - TypingIndicator: 3-dot bouncing animation shown before AI reply
   - Mock 8-turn conversation from chat_mock.dart, reveals message-by-message with 1.2s delay
   - SuggestedReplyChips: horizontal scrollable row below chat
   - SeveritySlider: 1–10, color shifts green→yellow→red
   - Voice mic FAB → bottom sheet placeholder
   - ChatProvider (StateNotifier): manages message list + typing state

3. features/ai_result/ai_result_screen.dart
   - Header: "AI Analysis Complete" + mode badge
   - ConditionCard (x3): condition name, confidence %, risk badge (Low/Med/High chip)
   - WHY section: explanation text with bullet points
   - Specialist recommendation card: doctor type + icon
   - Fast AI vs Deep Check comparison: fl_chart BarChart side-by-side
   - CTA row: Create Ticket / Nutrition Check / Start Monitoring / Deep Verify buttons

4. features/deep_check/deep_check_screen.dart
   - "Deep Medical Analysis" header with loading animation (3s mock)
   - Evidence cards list: symptom matched, confidence, source label
   - Why chosen section: text explanation
   - fl_chart BarChart: Fast AI vs Deep Check confidence per condition
   - Guideline references: 3 mock cards with journal name + year

SHARED WIDGETS:
   - shared/widgets/chat_bubble.dart (user + AI variants)
   - shared/widgets/typing_indicator.dart
   - shared/widgets/severity_slider.dart
   - shared/widgets/condition_card.dart
   - shared/widgets/risk_badge.dart
   - shared/widgets/ai_mode_badge.dart

Output all files completely.
```

---

## Phase 5 — Clinical Features

```
Continue MedAssist AI Flutter app. Phases 1–4 complete.
Build Tickets, Doctor Explorer, and Hospital screens.

1. features/tickets/ticket_list_screen.dart
   - Filter chips row: All / Open / In Progress / Resolved / Closed
   - TicketCard: left border color = urgency (red/orange/green), ticket ID, title,
     symptom summary, doctor avatar + name, status chip, progress bar, timestamp
   - FloatingActionButton: "New Ticket" → sheet or navigate to body map flow
   - TicketsProvider from tickets_mock.dart

2. features/tickets/ticket_detail_screen.dart
   - Hero on ticket title card
   - Symptom history: vertical timeline (TimelineStep widgets)
   - Doctor assigned card with online badge
   - Doctor Chat section: ChatBubble list (reuse from Phase 4), mock 3-turn conversation
   - Prescriptions list: medicine name, dosage, duration cards
   - Progress Timeline: 4-step (Created → Doctor Assigned → In Review → Resolved)
   - Report upload: dashed border box, upload icon, tap → SnackBar "Upload coming soon"
   - Patient note: TextField + Submit at bottom

3. features/doctors/doctor_explorer_screen.dart
   - Search bar with animated expand
   - Specialty filter chips: All / Cardiologist / General Physician / Neurologist /
     Dermatologist / Orthopedic / Psychiatrist
   - DoctorCard: avatar initials circle, name, specialty, hospital, rating stars,
     online/offline green-grey dot, "Consult Now" button, "₹499 / session" fee
   - DoctorsProvider from doctors_mock.dart with filter logic

4. features/hospitals/hospital_screen.dart
   - Map placeholder: Container with grey background + "Map View" text + location pin icon
   - "Nearby Hospitals" section header
   - HospitalCard x3: name, distance chip, emergency label (red badge), address,
     "Get Directions" + "Call" buttons
   - Floating SOS red button bottom right

SHARED WIDGETS:
   - shared/widgets/timeline_step.dart
   - shared/widgets/star_rating.dart
   - shared/widgets/doctor_card.dart
   - shared/widgets/hospital_card.dart
   - shared/widgets/urgency_badge.dart
   - shared/dialogs/filter_bottom_sheet.dart (reusable multi-select filter)

Output all files completely.
```

---

## Phase 6 — Health Tracking

```
Continue MedAssist AI Flutter app. Phases 1–5 complete.
Build Nutrition, Monitoring, Records, Pharmacy and health card screens.

1. features/nutrition/nutrition_search_screen.dart
   - Animated SearchBar (expands on tap)
   - Barcode scanner FAB → bottom sheet placeholder
   - Condition-based chips: Recovery Diet / Diabetic Safe / Low Sodium / High Protein
   - Recent foods list from nutrition_mock.dart with recovery-safe tag
   - NutritionProvider with search filter logic

2. features/nutrition/food_detail_screen.dart
   - Food name + image placeholder hero card
   - MacroCard grid 2×3: Calories / Carbs / Protein / Sugar / Fat / Sodium
     each with animated LinearProgressIndicator and daily% label
   - "Can I Eat This?" FilledButton → showModalBottomSheet with
     Fast AI card + Deep Check card (recommendation + reason)
   - RecoveryGauge: circular /100 score with color zones
   - Healthy alternatives: horizontal scroll FoodChipCards
   - Meal timing tips: icon + text list

3. features/monitoring/monitoring_screen.dart
   - Day stepper: 1–5 horizontal pills (current day highlighted)
   - "How are your symptoms today?" severity slider (reuse SeveritySlider)
   - Hydration tracker: 8 water cup icons, tap to fill (MonitoringProvider)
   - Sleep card: hours slider 4–12
   - Mood card: emoji selector row
   - Better / Same / Worse chips
   - "Save Today's Check-in" button → success bottom sheet

4. features/monitoring/recovery_report_screen.dart
   - "Recovery Summary — Day 5" header
   - Healing trend: fl_chart LineChart (5-day symptom severity data)
   - Food correlation: fl_chart BarChart (food score vs symptom score per day)
   - Recovery score card: large number /100 with badge
   - AI Prediction banner: "You are likely to fully recover in 2 days" with confidence %

5. features/records/health_records_screen.dart
   - Filter tabs: All / Prescriptions / AI Results / Lab Reports / Tickets
   - RecordCard: type icon, title, date, doctor name, "View" button
   - RecordsProvider from records_mock.dart

6. features/records/medassist_card_screen.dart
   - Digital card UI: gradient card, user name, ID, blood group
   - qr_flutter QR code widget with health ID
   - Chips: blood group, allergies list, chronic conditions
   - Emergency contact with call icon
   - "Share Card" + "Download PDF" buttons (SnackBar placeholders)

7. features/pharmacy/pharmacy_screen.dart
   - Medicine search bar
   - MedicineCard: name, dosage, brand, price, generic alternative chip, "Order" button
   - Price compare row: Brand price vs Generic price
   - Reminder setup: bottom sheet with time picker UI + repeat days selector

8. features/monitoring/daily_followup_screen.dart
   - Compact full-screen or bottom sheet
   - 4 quick questions with chip answers:
     Symptoms better/same/worse, Ate on time (Y/N), Hydration 8 cups (Y/N), Sleep quality

SHARED WIDGETS:
   - shared/widgets/macro_card.dart
   - shared/widgets/hydration_tracker.dart
   - shared/widgets/recovery_gauge.dart
   - shared/widgets/trend_chart.dart (fl_chart wrapper)
   - shared/widgets/record_card.dart
   - shared/widgets/digital_health_card.dart

Output all files completely.
```

---

## Phase 7 — SOS, Profile & Final Polish

```
Continue MedAssist AI Flutter app. Phases 1–6 complete.
Build SOS, Profile, and apply global polish.

1. features/sos/sos_screen.dart
   - Full-screen red background (#EF4444)
   - Giant SOS button: CircleAvatar 160px, pulsing scale+opacity animation loop
   - IMPORTANT: Wrap in LongPressGestureDetector 1.5s — show circular hold-progress
     ring that fills before activating (prevents accidental taps)
   - After activation: 3-ring expanding pulse animation "Sending your location..."
   - After 3s mock: green slide-in banner "Hospital Notified — City Hospital, 1.2km"
   - Emergency contacts row: avatar + name + call IconButton
   - Voice SOS: mic icon button → "Hold to speak" label
   - Cancel button (white outlined) at bottom

2. features/profile/profile_screen.dart
   - Profile header: avatar, name, age, blood group chip
   - Edit Profile: name/phone/email fields with edit icon toggle
   - Wearables section: placeholder grid (Apple Watch / Fitbit / Samsung cards with "Connect" buttons)
   - AI Mode preference: FilledButton toggle (Fast AI | Deep Check)
   - Emergency Contacts: list with add + delete
   - Privacy Settings: SwitchListTile widgets (data sharing, analytics, notifications)
   - App version + About
   - Logout: outlined red button → ConfirmDialog → clears state → /splash

3. Global polish — apply to ALL screens:
   - GoRouter transitions: CustomTransitionPage with SlideTransition (bottom-to-top for
     detail screens, right-to-left for forward nav)
   - Empty state widget: shared/widgets/empty_state.dart
     (illustration placeholder + headline + CTA button)
   - Error state widget: shared/widgets/error_state.dart
     (error icon + message + Retry button)
   - Success bottom sheet: shared/dialogs/success_sheet.dart
     (green checkmark lottie placeholder + message + Done button)
   - Global loading overlay: shared/widgets/loading_overlay.dart
   - Ensure all screens handle 375px width without overflow
   - Add resizeToAvoidBottomInset: true on all chat/form screens

4. Final build check:
   - Verify all GoRouter routes are connected (no dead links)
   - All providers properly dispose their AnimationControllers
   - Run flutter analyze — zero errors
   - flutter build apk --release must succeed

Output all files completely.
```

---

**Key improvements I've added over the original prompt:**

1. **Long-press SOS guard** — prevents accidental emergency activation
2. **ThemeNotifier** for dark mode toggle from Profile
3. **FilterBottomSheet** as reusable component across Doctor/Pharmacy/Records
4. **Hero animations** between Body Map → Chat for visual continuity
5. **MonitoringProvider** persisting session data so Recovery Report uses real inputs
6. **Pull-to-refresh** with shimmer re-trigger on Dashboard
7. **Each phase is fully self-contained** — you can prompt your IDE for exactly one phase at a time without context overflow
8. **App state restoration architecture** in Phase 1 (`core/state/app_state.dart`) for better restart UX
9. **Reusable app bottom sheet system** in Phase 1 (`shared/dialogs/app_bottom_sheet.dart`) to reduce duplicated UI
10. **Theme mode as first-class architecture** in Phase 1 (`core/theme/theme_notifier.dart`) with light/dark/system modes
11. **Reusable chart wrapper** in Phase 1 (`shared/widgets/app_chart_card.dart`) for consistent fl_chart presentation
12. **Compact empty-list placeholder widget** in Phase 1 (`shared/widgets/app_empty_list.dart`) for list-first screens
13. **Centralized mock delay helper** in Phase 1 (`core/utils/mock_delay.dart`) to avoid repeated `Future.delayed` usage
14. **Reusable section card shell** in Phase 1 (`shared/widgets/app_section_card.dart`) for consistent card UI and less duplication
