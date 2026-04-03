# MedAssist AI — Final Hackathon Implementation Plan

This document defines the final phase-wise implementation roadmap for converting the existing Flutter mock-data UI into a fully working AI-powered healthcare hackathon product.

The frontend UI foundation is already complete.

Goal now:
> Replace mock providers with real Supabase + Edge Function architecture while preserving demo-safe fallback mode.

---

# 🏗 Overall Execution Roadmap

```text
Day 1 → Backend foundation + Hero AI chat flow
Day 2 → Nutrition intelligence + Food vision + start Mini RAG
Day 3 → Mini RAG + Monitoring recovery + Demo seed data + final polish
```

---

# 🚀 DAY 1 — Backend Foundation + Hero AI Flow

# ✅ Phase 1 — Backend Foundation
## 🎯 Goal
Replace mock state with real Supabase-ready architecture.
Touch data layer only.

---

## 📁 Folder Structure

Create:

```text
lib/core/
  services/
    supabase_service.dart
    edge_function_service.dart

  repositories/
    auth_repository.dart
    chat_repository.dart
    nutrition_repository.dart
    monitoring_repository.dart
    rag_repository.dart
```

---

## ⚙️ Service Responsibilities

### `supabase_service.dart`
Responsibilities:
- Supabase singleton client
- auth session access
- DB CRUD wrappers
- future realtime hooks

---

### `edge_function_service.dart`
Responsibilities:
- invoke edge functions
- inject Supabase JWT auth header
- timeout handling
- retry support
- structured JSON decode
- error parsing

---

## 🗄 Database Tables

Create these tables in Supabase.

### `profiles`
```sql
id uuid primary key
name text
age int
gender text
conditions text[]
allergies text[]
created_at timestamptz
```

### `symptom_sessions`
```sql
id uuid primary key
user_id uuid
body_part text
severity int
mode text
created_at timestamptz
```

### `symptom_messages`
```sql
id uuid primary key
session_id uuid
role text
message text
created_at timestamptz
```

### `nutrition_logs`
```sql
id uuid primary key
user_id uuid
food_name text
calories int
sodium_mg int
is_safe bool
meal_type text
image_url text
created_at timestamptz
```

### `monitoring_logs`
```sql
id uuid primary key
user_id uuid
sleep_hours int
hydration_glasses int
pain_level int
mood text
symptom_trend text
created_at timestamptz
```

### `tickets`
```sql
id uuid primary key
user_id uuid
condition text
status text
priority text
created_at timestamptz
```

### `embeddings`
```sql
id uuid primary key
user_id uuid
source_type text
source_id uuid
content text
embedding vector(1024)
created_at timestamptz
```

---

## 🔐 Auth Rules
Flutter stores only:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Never store:
```text
service_role
Kimi API key
medical KB secrets
```

These must stay inside:
```text
Supabase Edge Function secrets
```

---

## 🛟 Fallback Mock Mode
This is mandatory for hackathon demo safety.

Inside repositories:

```dart
bool useMock = true;
```

Default must remain `true`.

Flip to `false` only after backend is stable.

---

# 🧠 Phase 2 — Hero AI Flow
## 🎯 Goal
Make the main symptom journey fully real.

Flow:
```text
Body Map → Symptom Chat → AI Result → Deep Check
```

---

## ⚙️ Edge Function
Create:

```text
supabase/functions/symptom-chat
```

---

## 📥 Input
```json
{
  "body_part": "stomach",
  "severity": 6,
  "chat_history": [],
  "user_memory": {}
}
```

---

## 📤 Output
```json
{
  "reply": "This could be gastritis or acid reflux.",
  "conditions": [
    {
      "name": "Acidity",
      "confidence": 84,
      "risk": "medium"
    }
  ],
  "risk": "medium",
  "next_question": "Did you eat spicy food recently?",
  "recommended_action": "Avoid oily meals and monitor for 24h"
}
```

---

## 🧠 AI Modes
### ⚡ Quick AI
- Kimi K2.5 short prompt
- no retrieval
- no memory
- token cap: 400

### 🧠 Deep Check
- Kimi K2.5
- inject past symptoms
- inject food triggers
- inject tickets
- inject monitoring trends
- top 3 embedding retrieval
- medical KB chunks

---

## 💬 Provider Migration
Replace:
```text
ChatProvider → mock delayed responses
```

With:
```text
ChatProvider → ChatRepository → symptom-chat edge function
```

---

## 💾 Conversation Persistence
Save every user + assistant message into:

```text
symptom_messages
```

This powers Mini RAG on Day 2.

---

# 🍛 DAY 2 — Nutrition Intelligence + Start Mini RAG

# ✅ Phase 3 — Nutrition Intelligence
## 🎯 Goal
Make food intelligence real.

---

## 📦 Barcode Layer
Use:
```text
OpenFoodFacts API
```

Best for:
- chips
- noodles
- biscuits
- drinks
- packaged snacks

No API key required.

---

## 📷 Food Vision Layer
Use:
```text
Kimi K2.5 Vision
```

Prompt:
```text
Analyze this food image.
Estimate:
- likely dish
- portion size
- calories
- oil level
- sodium risk
- stomach recovery impact
Return structured JSON.
```

Best for:
- Indian food
- restaurant meals
- fast food
- unpackaged meals

---

## 💾 Save Logs
Store into:
```text
nutrition_logs
```

Required fields:
```text
food_name
calories
sodium_mg
is_safe
meal_type
image_url
timestamp
```

---

## 📱 Connect Real Screens
Connect backend for:
```text
nutrition_search_screen
food_detail_screen
```

---

# 🧠 Phase 4 — Mini RAG + Health Memory
## 🎯 Goal
Enable memory-aware medical reasoning.

---

## 🧠 Retrieval Layer 1 — Personal Memory
Retrieve:
- past symptoms
- unsafe foods
- allergies
- previous tickets
- recovery trends
- sleep + hydration history

---

## 📚 Retrieval Layer 2 — Mini Medical KB
Hackathon scope:
```text
100 curated chunks only
```

Priority domains:
- stomach pain
- acidity
- GERD
- food allergy
- dehydration
- sodium-heavy foods
- headache
- fever

Store vectors inside:
```text
embeddings
```

---

## ⚡ Retrieval Strategy
Use:
```text
top_k = 3
```

Never retrieve more than 3 chunks for hackathon latency.

---

## 🖥 UI Upgrade Targets
Upgrade:
```text
deep_check_screen.dart
ai_result_screen.dart
```

Memory-aware examples:
```text
Based on your spicy noodles yesterday and your GERD history...
```

---

## 🛟 RAG Fallback Rule
If RAG becomes unstable:
> use pre-seeded retrieval examples from demo user.

Smooth demo > broken live retrieval.

---

# 📈 DAY 3 — Monitoring + Recovery + Demo Polish

# ✅ Phase 5 — Monitoring + Recovery
## 🎯 Goal
Create visible healing story.

Connect:
```text
monitoring_screen
recovery_report_screen
```

---

## 💾 Save Daily Check-ins
Store:
- sleep
- hydration
- pain
- mood
- symptom trend

into:
```text
monitoring_logs
```

---

## 🧠 Recovery Prediction
Generate:
```text
You may recover in 2 days because hydration improved and sodium intake decreased.
```

This can be simple LLM summarization.

---

# 🎬 Phase 6 — Demo Polish + Seed Data
## 🎯 Goal
Make judges emotionally feel the recovery journey.

---

## 👤 Demo Seed User
Create seeded user:

```text
Name: Rahul
Condition: GERD
Yesterday Meal: spicy instant noodles
Hydration Day 1: 3/8
Pain Day 1: 7
Hydration Day 5: 8/8
Pain Day 5: 2
```

---

## 🏆 Scripted Judge Demo Flow
Use this exact demo:

```text
1. Select stomach
2. AI asks adaptive follow-up questions
3. Scan instant noodles
4. Sodium warning triggered
5. Start Day 1 monitoring
6. Open Day 5 recovery chart
7. Deep Check cites GERD history + spicy trigger
8. AI predicts recovery in 2 days
```

---

# 🚨 Final Screen Priority

## P0 — Must Work
```text
body_map
symptom_chat
ai_result
nutrition_search
food_detail
monitoring
recovery_report
```

## P1 — Strong Add-on
```text
deep_check
tickets
records
```

## P2 — Optional Polish
```text
profile
sos
pharmacy
```

---

# 🏁 Final Hackathon Rule
Do NOT build extra screens now.

Priority is:
> Make hero journey fully real and deeply polished.

Winning factor:
```text
Adaptive AI + Food intelligence + Memory-aware recovery story
```