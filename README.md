# Visitor Management Mobile Application

An enterprise-grade Flutter mobile application for managing visitor registration, real-time check-in/check-out tracking, QR code verification, and visitor analytics.

---

## 📱 Features

- **📊 Real-time Dashboard**:
  - Live metric cards: *Total Visitors Today*, *Currently Checked In*, *Checked Out Today*, and *Total All-Time Records*.
  - Quick action shortcuts for quick visitor registration and QR scanner access.
  - API endpoint configuration alert banner for mock or production environments.

- **📇 Visitor Directory & Search**:
  - Live search filter by visitor **Name**, **Phone Number**, or **Project**.
  - Category status filters (*All*, *Registered*, *Checked In*, *Checked Out*).
  - Pull-to-refresh list integration.

- **✍️ Visitor Registration & Editing**:
  - Form validation for Name, Mobile Number, Visitor Type, Project, and Purpose.
  - Profile update support while preserving existing check-in/check-out timestamps and status.

- **📷 QR Code Scanner & Pass Generation**:
  - Integrated QR scanner (`mobile_scanner`) to quickly read visitor passes on arrival or departure.
  - Instant lookup of visitor profiles from scanned QR IDs.
  - QR Pass rendering (`qr_flutter`) on visitor detail pages for easy check-in verification.

- **⚡ State Machine & Lifecycle Management**:
  - Enforced status lifecycle: `Registered` ➔ `Checked In` ➔ `Checked Out`.
  - Automatic timestamp tracking (`created_at`, `check_in_time`, `check_out_time`).
  - Validation rules preventing illegal state transitions (e.g., checking out without checking in first).

- **🎨 Modern Material 3 UI/UX**:
  - Clean layered navigation shell with bottom navigation bar.
  - Custom branded theme, status chips, responsive dialogs, loading states, and error view overlays.

---

## 🏗️ Architecture & Tech Stack

This project follows a **Layered Feature-First Architecture**:

```text
lib/
├── app.dart                   # Main app widget & navigation shell
├── main.dart                  # Application entry point with ProviderScope
├── core/                      # Application core (constants, config, theme, network, errors)
│   ├── config/app_config.dart # Environment loading & API URL resolution
│   ├── constants/             # Colors, endpoints, UI strings
│   ├── errors/                # Custom exceptions (AppException, ApiClient error mapping)
│   ├── network/               # Dio HTTP client configuration & interceptors
│   ├── theme/                 # Material 3 light/dark theme data
│   └── utils/                 # Date formatters and field validators
├── data/                      # Data layer (API service & repository)
│   ├── visitor_api_service.dart # Low-level REST API endpoints (GET, POST, PUT, DELETE)
│   └── visitor_repository.dart  # Business logic repository & state transition rules
├── models/                    # Domain models
│   └── visitor.dart           # Visitor entity, JSON serialization, copyWith, transition getters
├── providers/                 # Riverpod state providers
│   └── visitor_providers.dart # VisitorListNotifier, Search, Status Filter, and Dashboard metrics
├── shared/                    # Reusable shared widgets (buttons, cards, inputs, dialogs)
└── features/                  # Feature screens and feature-specific widgets
    ├── dashboard/             # Dashboard screen & metric widgets
    ├── scanner/               # Camera QR scanner screen
    └── visitors/              # Directory list, detail view, and registration/edit forms
```

### Key Technologies
- **Flutter** (SDK `^3.10.1`)
- **Flutter Riverpod** (`^3.3.2`) - State management using `AsyncNotifier` and `Provider`
- **Dio** (`^5.11.1`) - HTTP network client with error handling
- **flutter_dotenv** (`^6.0.1`) - Environment variable management (`.env`)
- **mobile_scanner** (`^7.4.2`) & **qr_flutter** (`^4.1.0`) - QR code scanning & rendering

---

## ⚙️ How it Works (State Machine & Business Logic)

### 1. Status Flow & Rules
Each visitor transitions through predefined states:

| Status | Valid Next State | Trigger Action | Timestamps Recorded |
| :--- | :--- | :--- | :--- |
| **Registered** | `Checked In` | Tap "Check In" or scan QR code | `created_at` |
| **Checked In** | `Checked Out` | Tap "Check Out" or scan QR code | `check_in_time` |
| **Checked Out** | *(Terminal state)* | Visit completed | `check_out_time` |

### 2. API & Data Flow
1. **Repository** (`VisitorRepository`): Translates API calls into `Visitor` domain models and validates state machine transitions.
2. **Notifier** (`VisitorListNotifier`): Manages the global reactive visitor state across the app. When a visitor is created, updated, checked in/out, or deleted, the list state updates immediately across all screens.
3. **Dashboard Provider** (`dashboardMetricsProvider`): Automatically recalculates statistics whenever the visitor list updates.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.1 or higher)
- Android Studio / Xcode / VS Code with Flutter extension
- An Android device/emulator or iOS simulator

### 1. Clone the repository
```bash
git clone <repository-url>
cd Visitor-Management-Mobile-Application
```

### 2. Configure Environment Variables
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```
*(Optionally replace `API_BASE_URL` in `.env` with your REST API server or MockAPI endpoint).*

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the application
```bash
flutter run
```

---

## 🧪 Testing

Run the full unit and widget test suite:

```bash
flutter test
```

Tests cover:
- Visitor model JSON serialization & copyWith logic
- Status transition rules (`canCheckIn`, `canCheckOut`)
- Metric calculation logic for dashboard
- Repository API interactions
- Input validators (Name, Mobile, Email)
- UI Widget rendering (Visitor cards, Status chips, Navigation shell)
