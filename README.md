# GAIL Canteen Services

A Flutter-based canteen ordering & catering-request workflow for GAIL's
Jubilee Tower office — built as **two apps sharing one codebase**.

---

## Two apps, one repo

| | GAIL Canteen (Admin) | Contractor Portal |
|---|---|---|
| **Entry point** | `lib/main.dart` | `lib/main_contractor.dart` |
| **Who uses it** | Admin, Initiator, Approver, HR (GAIL staff) | External kitchen contractor (e.g. Royal Caterers) |
| **What it does** | Submit, approve, and finally sign off catering requests; manage contractors, menus, reports; and view real-time kitchen status | Log in externally via email + OTP, view today's approved orders, and mark them Received → Prepared → Served |
| **Run it** | `flutter run` | `flutter run -t lib/main_contractor.dart` |

They are **compiled as two completely separate apps** — the Contractor
Portal never appears anywhere in the Admin app's navigation, and vice
versa. What they *do* share is the underlying Dart code: both entry
points import the exact same `lib/models/models.dart` (data structures
+ mock in-memory store), `lib/theme/app_theme.dart` (GAIL branding), and
`lib/widgets/shared_widgets.dart` (common UI pieces) — so there's a
single source of truth for data shapes and business rules, not two
implementations drifting apart.

## Why this structure

- **Separate app, correct permissions story.** The Contractor is an
  external vendor who should never see GAIL's internal Admin/HR
  screens — a separate compiled app enforces that at the binary level,
  not just with a login check.
- **One codebase to maintain.** Bug fixes or model changes (e.g. adding
  a new order status) are made once and both apps pick it up on their
  next build — no copy-pasting logic between two repos.

## Project structure

```
lib/
├── main.dart                      # Entry point: Admin/Initiator/Approver/HR app
├── main_contractor.dart           # Entry point: standalone Contractor app
├── models/
│   └── models.dart                # Shared data models + mock AppDataStore
├── theme/
│   └── app_theme.dart             # Shared GAIL branding (colors, text styles)
├── widgets/
│   └── shared_widgets.dart        # Shared UI components (AppBar, EmptyState, etc.)
└── screens/
    ├── admin/                     # Contractor Mapping, Menu Mgmt, MIS Reports,
    │                               # Authorization, Contractor Status (read-only)
    ├── initiator/                 # Create & track catering requests
    ├── approver/                  # First-level approval
    ├── hr/                        # Final approval → dispatches to contractor
    └── contractor/                # Contractor login + Today's Service screen
                                    # (only reachable via main_contractor.dart)
```

## Getting started

```bash
flutter pub get

# Run the main GAIL Canteen app (Admin/Initiator/Approver/HR):
flutter run

# Run the Contractor Portal as a separate app:
flutter run -t lib/main_contractor.dart
```

Both can be run at the same time on two different devices/emulators to
see the full workflow end-to-end: an Initiator submits a request, it
flows through Approver → HR, and once HR gives final approval it shows
up in the Contractor Portal's "Active Orders."

## Current status / known limitation

Data currently lives in an **in-memory mock store** (`AppDataStore` in
`models.dart`), seeded with sample requests and contractors. Because
each running instance of either app has its own private memory (they
are separate compiled processes), a status update made in one running
Contractor Portal (e.g. marking an order "Served") will **not**
automatically appear in a separately running Admin app — that requires
a real backend/API both apps call into instead of a local singleton.
The `AppDataStore` class is a single, well-defined place to swap in
real HTTP calls (e.g. inside its request/contractor getters and the
methods that mutate `contractorStatus`) once a backend exists, without
having to touch the UI screens themselves.

## Tech stack

- Flutter / Dart
- `intl` for date formatting
- Material Design 3
A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
