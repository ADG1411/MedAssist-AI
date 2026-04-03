# MedAssist AI — Backend Integration Instructions

This file defines the engineering rules for converting the existing Flutter mock-data frontend into a real Supabase + Edge Function powered hackathon application.

The UI foundation is already complete.

## 🚨 Critical Rule
Do NOT redesign screens.

This phase is:
> backend integration + provider migration + minor state-safe UI upgrades only

The visual design system, routes, animations, and widgets must remain unchanged unless explicitly required for backend compatibility.

---

# 🏗 Architecture Rules

## ✅ Repository-first pattern
All providers must follow:

```text
Provider → Repository → Service → Supabase / Edge Function
```

Never call Supabase directly inside:
- screens
- widgets
- Riverpod providers

---

## ✅ Services layer rules
### `supabase_service.dart`
Must contain only:
- singleton client
- auth helpers
- table access helpers
- future realtime hooks

No business logic.

---

### `edge_function_service.dart`
Must contain only:
- edge invocation
- JWT auth injection
- timeout
- retry
- structured decode
- error parsing

No UI logic.

---

## ✅ Repository rules
Each repository must support dual mode:

```dart
bool useMock = true;
```

Pattern:

```dart
if (useMock) {
  return mockResponse;
} else {
  return liveSupabaseResponse;
}
```

This fallback mode is mandatory for demo safety.

---

# 📱 Frontend Screen Changes Allowed In This Phase

Only apply these backend-safe changes.

---

# ✅ 1. `symptom_chat_screen.dart`
## Required updates
- connect send button to `ChatProvider.sendMessage()`
- support async loading state from edge function
- preserve typing indicator
- append real AI response
- save `session_id`
- support AI mode toggle payload (`quick`, `deep`)

## UI must NOT change
- bubble design
- typing animation
- severity slider
- suggested reply chips

---

# ✅ 2. `ai_result_screen.dart`
## Required updates
Bind screen to live response payload:
- conditions[]
- confidence
- risk
- recommended_action
- next_question fallback CTA

### Add safe loading state
Use existing shimmer / skeleton while waiting for edge response.

---

# ✅ 3. `deep_check_screen.dart`
## Required updates
This screen must now support:
- retrieved memory context
- top 3 KB references
- nutrition trigger context
- previous ticket reference

### Add one optional section
```text
Why this matches your history
```

Use:
- previous symptoms
- food trigger
- recovery trend

This is important for RAG storytelling.

---

# ✅ 4. `nutrition_search_screen.dart`
## Required updates
- barcode result from OpenFoodFacts
- live search result binding
- image scan trigger
- loading state while Kimi Vision runs

UI remains unchanged.

---

# ✅ 5. `food_detail_screen.dart`
## Required updates
Bind to real backend fields:
- calories
- sodium_mg
- is_safe
- recovery impact
- alternatives
- image_url

### Add one backend-safe field
```text
reason
```

Example:
```text
Unsafe because sodium is high and your previous GERD history shows sensitivity.
```

This improves judge storytelling.

---

# ✅ 6. `monitoring_screen.dart`
## Required updates
Persist:
- hydration
- sleep
- mood
- pain
- trend

The UI is already strong.
No redesign required.

---

# 🧠 Provider Migration Rules

## Existing providers to migrate now
Priority:

```text
ChatProvider
NutritionProvider
MonitoringProvider
AuthProvider
```

Pattern:

```text
Old:
Provider → mock data

New:
Provider → repository → services
```

---

# 🔐 Auth Rules
Every edge function request must include:

```http
Authorization: Bearer <supabase_jwt>
```

JWT must come from current session.

Never hardcode tokens.

---

# 🧠 RAG Rules (Hackathon Scope)
Mini RAG only.

Allowed retrieval sources:
- symptom_messages
- nutrition_logs
- monitoring_logs
- tickets
- embeddings

Use:
```text
top_k = 3
```

Do NOT implement large-scale internet medical RAG in this phase.

---

# 🎬 Demo Safety Rules
Always preserve:
```dart
bool useMock = true;
```

If any backend call fails:
- automatically fallback to mock mode
- preserve user flow
- do not crash screen
- keep demo story intact

This is a hackathon-critical requirement.

---

# 🚫 Do NOT Change In This Phase
Do NOT modify:
- navigation routes
- onboarding
- splash
- profile layout
- SOS animations
- global theme
- reusable widgets styling
- bottom navigation shell

These are already complete.

---

# 🏆 Success Criteria For This Phase
This phase is successful when this live flow works:

```text
Body Map
→ Symptom Chat
→ AI Result
→ Deep Check
→ Nutrition Scan
→ Monitoring Save
→ Recovery Chart
```

with:
- real Supabase persistence
- real edge AI calls
- fallback mock safety
- no UI redesign regressions