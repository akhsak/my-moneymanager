# Money Manager

## Project Overview
Money Manager is a Flutter application that helps users track expenses, manage categories, and view analytics. It supports both authenticated users (via REST APIs) and guest users (via Hive storage). The codebase follows a clean architecture layout with clear separation between presentation, domain, and repository layers.

## Features
- Dual data sources: remote API for authenticated users, Hive persistence for guest users
- Category management with guest/API refresh logic
- Transaction tracking, sub-transaction editing, and auto-transactions
- Analytics dashboards with guest-mode fallbacks
- Authentication (signup, login, forgot password) with cleared form states
- In-app help center that combines FAQ and contact options
- Online support chat history (active/ended) mock UI

## Installation
1. Install Flutter (3.24+) and Dart (3.5+) along with Android/iOS toolchains.
2. Clone the repo:
   ```bash
   git clone <repo-url>
   cd money_manager
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Configure environment variables (see API Instructions).
5. Run the app on an emulator or device:
   ```bash
   flutter run
   ```

## Folder Structure
```
lib/
├── core/                 # Constants, services, shared widgets
├── presentation/         # UI screens, controllers, widgets
├── repository/           # Data sources, models, g.dart files
└── main.dart             # App bootstrap
```

## Screenshots
Add screenshots (PNG/JPG) to `assets/screenshots/` and embed them here:
```
![Home](assets/screenshots/home.png)
![Categories](assets/screenshots/categories.png)
![Analysis](assets/screenshots/analysis.png)
```

## API Instructions
- Base URL: `https://money-manager-web.onrender.com/api`
- Authentication: Bearer token stored via secure storage; absence of token puts the app in guest mode.
- Endpoints used:
  - `/categories`, `/categories/{id}/transactions`, `/categories/category-analytics`
  - `/expenses/auto-transactions`
  - `/reminders`
- Guest mode uses `Hive` boxes `guest_categories`, `guest_transactions`, and includes migration safeguards.
- Update `lib/core/constants/api_endpoints.dart` (or equivalent) if the backend URL changes.

## Common Commands
```bash
flutter clean
flutter pub get
flutter run                   # debug build
flutter test                  # run unit/widget tests
flutter build apk             # release Android build
flutter build ios --release   # release iOS build
```

Feel free to expand each section with more project-specific details as the app evolves.
