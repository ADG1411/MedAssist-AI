# MedAssist AI Codebase Index

This document provides a comprehensive map of the current MedAssist AI project structure to aid in future development, debugging, and feature additions. The project follows a feature-first architectural pattern combined with global shared layers.

## 📁 Directory Structure Overview

### 1. `lib/core/` — Global Infrastructure
Contains all configurations, global state, and data layers that serve the entire app.

- **`constants/`**
  - `app_constants.dart`: Global strings, mockup delays, and asset boundaries.
- **`mock/`**
### 6. Mock Data & Fallbacks
- `lib/core/mock/chat_mock.dart`: Holds the AI consultation raw fallbacks.
- `lib/core/mock/tickets_mock.dart`: Seed data for hospital queues.
- `lib/core/mock/history_mock.dart`: Timeline medical history.
- `lib/core/mock/nutrition_mock.dart`: Visual meal replacements.
- `lib/core/mock/user_mock.dart`: Defines the "Rahul / GERD" demo persona.
- `lib/core/utils/mock_delay.dart`: Simple 2-3s delay generator for simulating heavy computation.

---

# 🚀 BACKEND INTEGRATION COMPLETE
> All 6 Phases of the `implmentationofbackend.md` rules have been strictly adhered.
> The UI securely routes mock delays and gracefully switches environments utilizing `useMock == true` via `.env`.s handling `useMock = true` logic safely routing between `core/mock/` data pools and `core/services/` logic.
  - Files: `auth_repository.dart`, `chat_repository.dart`, `monitoring_repository.dart`, `nutrition_repository.dart`, `rag_repository.dart`.
- **`router/`**
  - `app_router.dart`: Enterprise GoRouter configuration managing all 22 static and dynamic routes. Contains the `ShellRoute` wrapper for bottom navigation.
- **`state/`**
  - `app_state.dart`: Blueprint for serialized app preferences (AI Modes, Theme Mode). Ready for downstream backend plugging.
- **`services/`**
  - `edge_function_service.dart`: Handles RPC JWT invocations formatting dynamic retries against the Supabase cloud.
  - `supabase_service.dart`: Encapsulates the core authenticated `Supabase.instance.client` singleton globally.
- **`theme/`**
  - `app_colors.dart`: Standardized color system palette.
  - `app_theme.dart`: Central Material 3 configs for Light and Dark modes. Handles element theming (InputDecoration, Cards, Buttons).
  - `theme_notifier.dart`: Riverpod Notifier dictating active `ThemeMode`.
- **`utils/`**
  - `mock_delay.dart`: Universal `MockDelay` class representing async network delays.

### 2. `lib/features/` — Domain Modules
Independent logic and UI blocks organized by functional domains.

- **`ai_result/`**
  - `ai_result_screen.dart`: Visualizes matching conditions with a comparative confidence BarChart between Fast and Deep analysis.
- **`auth/`**
  - `providers/auth_provider.dart`: Riverpod Notifier resolving phone + OTP auth state mechanics.
  - `login_screen.dart`: Multi-tab interface (Phone & Email) with inputs and biometrics placeholders.
  - `otp_screen.dart`: Countdown page and 6-field OTP verification bridging to `/home`.
- **`body_map/`**
  - `providers/symptom_check_provider.dart`: Tracks tapped regions and multi-selected symptom descriptors.
  - `body_map_screen.dart`: Interactive anatomical selector for physical symptoms.
- **`dashboard/`**
  - `providers/dashboard_provider.dart`: Mock API initializer exposing `isLoading` state.
  - `home_screen.dart`: Primary viewport combining quick actions, active active trackers, and AI outcomes.
- **`deep_check/`**
  - `deep_check_screen.dart`: Heavy mock process state leading into clinical reference tracking and mapped diagnostic confidences.
- **`doctors/`**
  - `providers/doctors_provider.dart`: Mock database logic filtering `DoctorCard` artifacts by queries and generic medical specialties.
  - `doctor_explorer_screen.dart`: Animated search bar housing grid queries for professional medical assistance.
- **`hospitals/`**
  - `hospital_screen.dart`: Map container mapping distance, routing logic, and SOS contacts for listed external properties.
- **`monitoring/`**
  - `providers/monitoring_provider.dart`: Logic tracking sleep indices, hydration cups (0-8), and generalized severity maps.
  - `monitoring_screen.dart`: Deep daily logging framework for water, sleep, mood, and pain.
  - `recovery_report_screen.dart`: Analytical breakdown mapping past 5-day symptom progressions via Fl_Chart vectors.
  - `daily_followup_screen.dart`: A rapid-entry pulse check assessing adherence to standard recovery metrics layout.
- **`nutrition/`**
  - `providers/nutrition_provider.dart`: Drives food querying through arrays defined in `nutrition_mock.dart`.
  - `nutrition_search_screen.dart`: Expanded catalog allowing targeted filter searches for diets (Diabetic Safe, Low Sodium).
  - `food_detail_screen.dart`: Intensive visual analysis for macronutrients (carbs, proteins, macros) and AI safety verdicts.
- **`onboarding/`**
  - `onboarding_screen.dart`: 3-stage page view showcasing primary application values.
- **`pharmacy/`**
  - `providers/pharmacy_provider.dart`: Mock commerce layer filtering out medicines and evaluating pricing differences.
  - `pharmacy_screen.dart`: Generic search list promoting cost-effective, non-brand specific pharmaceutical equivalencies.
- **`profile/`**
  - `profile_screen.dart`: Config interface handling data sharing bounds, emergency contacts, and fast-AI modes.
- **`records/`**
  - `providers/records_provider.dart`: Classifying and retrieving Lab Reports, Prescriptions, and AI Results.
  - `health_records_screen.dart`: Global categorized vault rendering mapped `record_card.dart` interfaces.
  - `medassist_card_screen.dart`: Digital Health Passport parsing mock ID fields to an interactive QR format.
- **`sos/`**
  - `sos_screen.dart`: Animated LongPress emergency dispatch UI handling dispatch tracking animations.
- **`splash/`**
  - `splash_screen.dart`: Animated application boot state wrapping a Canvas-driven ECG path.
- **`symptom_chat/`**
  - `providers/chat_provider.dart`: Drives multi-turn sequential chat responses leveraging simulated async delays.
  - `symptom_chat_screen.dart`: Chat UI housing messages, typing indicators, horizontal reply chips, and a severity slider widget.
- **`tickets/`**
  - `providers/tickets_provider.dart`: Notifier encapsulating filtering constraints and specific ID fetching logic globally.
  - `ticket_list_screen.dart`: Filterable list rendering Active, Progressing, and Completed user problem reports.
  - `ticket_detail_screen.dart`: Extensive timeline visualizing doctor assignment, prescriptions, and upload placeholder UI.

### 3. `lib/shared/` — Reusable Building Blocks
Agnostic UI components used repetitively across all features.

- **`dialogs/`**
  - `app_bottom_sheet.dart`: Reusable modal bottom sheet standardized with drag handles and rounded cards.
  - `filter_bottom_sheet.dart`: Dynamically generated custom single-choice radio list tile UI mapped to array configurations.
  - `success_sheet.dart`: Animated confirmation modal bridging transactional closures (appointments, saves).
- **`navigation/`**
  - `scaffold_with_bottom_nav.dart`: Fixed navigation bar encapsulating children from the router shell. Contains global floating SOS button.
- **`widgets/`**
  - `ai_mode_badge.dart`: Pill indicator toggling Fast AI / Deep Check contexts.
  - `app_button.dart`: Base CTA handler (variants: Primary, Ghost, Secondary).
  - `app_chart_card.dart`: Graph wrapper UI for future FLChart inputs.
  - `app_empty_list.dart`: Standard placeholder view when no list data exists.
  - `app_section_card.dart`: White-container encapsulation for grouping items.
  - `app_text_field.dart`: Standard input shell controlling theme and prefixes.
  - `base_screen.dart`: Master template covering SafeAreas, generic AppBars, and Backgrounds.
  - `chat_bubble.dart`: Themed message cards adjusting dynamically per AI or User origin.
  - `condition_card.dart`: Container listing disease hypothesis bounds.
  - `digital_health_card.dart`: Advanced gradient UI passing strings into an operational embedded QrImageView.
  - `doctor_card.dart`: Interactive surface handling name, badge, and consult cost constraints.
  - `error_state.dart`: Standardized Fallback view projecting errors with recursive "Retry" callback parameters.
  - `health_score_ring.dart`: Animated 360-degree Score arc painted manually via Canvas.
  - `hospital_card.dart`: Proximity and address rendering interface paired with directional and calling intents.
  - `hydration_tracker.dart`: Array-based clickable water drop row calculating 8-glass metrics.
  - `macro_card.dart`: A statistical container framing explicit food-percentage nutritional variables.
  - `otp_input.dart`: 6-field character autoscroller.
  - `page_dot_indicator.dart`: Dynamic width slider points for page views.
  - `quick_action_card.dart`: 2x2 grid selection pods (Nutrition, Tickets, SOS).
  - `record_card.dart`: Adaptive UI element alternating semantics and icons conditionally against Record document strings.
  - `recovery_gauge.dart`: Custom radial Canvas painter mapping static arc scores spanning 0 to 100 percentages.
  - `risk_badge.dart`: Small tag formatting risk labels (Low, Medium, High) with corresponding semantic colors.
  - `section_header.dart`: Titular rows with "View All" actions.
  - `severity_slider.dart`: 1-10 range slider blending colors based strictly on numeric threshold.
  - `shimmer_box.dart`: Unified skeleton loader bridging latency.
  - `star_rating.dart`: Generates accurate partial and full star icons mathematically aligned to decimals.
  - `status_chip.dart`: Multi-colored capsule badges (Warning, Danger, Success).
  - `timeline_step.dart`: Vertical process pipeline node supporting timeline sequencing.
  - `trend_chart.dart`: Integrated wrapper encapsulating FlChart mapping coordinates against specific Y-Axis behaviors.
  - `typing_indicator.dart`: Bouncing 3-dot animation simulating AI thought latency.
  - `urgency_badge.dart`: Pre-formatted alert capsules (High/Medium/Low) parsing semantic context colors.

### 4. `lib/main.dart`
The root bootstrapper integrating `ProviderScope` to launch the Riverpod tree alongside resolving the standard `AppRouter`.

## 🛠 Flow Maps for Troubleshooting

When debugging or extending the application, follow these state layers:
1. **Routing Bugs?** Look within `lib/core/router/app_router.dart` and `scaffold_with_bottom_nav.dart` to debug view mounting issues. 
2. **State & Logic Issues?** Reference `dashboard_provider.dart` and `auth_provider.dart`. 
3. **UI/Styling Issues?** Components draw their tokens strictly from `app_theme.dart` and `app_colors.dart`. Avoid hardcoding hex-colors to maintain consistency!
