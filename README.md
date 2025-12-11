# PantryPal

PantryPal is a smart inventory management application developed in Flutter. It helps users reduce food waste by tracking expiry dates and recommending recipes based on available ingredients.

## Features (MVP)

1.  **Inventory Management**:
    - **Dashboard**: A FIFO-sorted list of your pantry items with color-coded expiry indicators (Green: Safe, Yellow: Warning, Red: Critical).
    - **Smart Entry**: Add items quickly with category chips that auto-suggest expiry dates.
    - **Offline Support**: All inventory data is stored locally using SQLite.
2.  **Recipe Generator**:
    - **Ingredient Matching**: Select items from your pantry to find recipes (Powered by TheMealDB).
    - **Search**: Manually search for recipes.
3.  **Local Execution**: Designed to run seamlessly on your local machine (Windows/Android).

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** design pattern implemented using **BLoC (Business Logic Component)**.

- **Logic (ViewModel)**: `InventoryBloc`, `RecipeBloc`. Handles state changes and events.
- **Data (Model)**: `InventoryItem`, `Recipe`.
- **UI (View)**: Screens (`DashboardScreen`, `RecipeSearchScreen`, `AddItemScreen`) that consume states from BLoCs.
- **Services**: `DatabaseHelper` (SQLite), `RecipeProvider` (Dio), `NotificationService`.

## Directory Structure

```
lib/
├── main.dart                  # App Entry Point & Providers
├── core/
│   ├── theme/                 # App Theme (Colors, Fonts)
│   └── utils/                 # DateHelpers, Constants
├── data/
│   ├── models/                # Data Models
│   ├── database/              # SQLite Helper
│   ├── content/               # API Providers
│   └── repositories/          # Repositories (Data Layer Abstraction)
├── logic/
│   ├── inventory/             # Inventory BLoC
│   └── recipe/                # Recipe BLoC
└── ui/
    ├── screens/               # App Screens
    └── widgets/               # Reusable Widgets
```

## Setup & Running

1.  **Prerequisites**: Flutter SDK installed.
2.  **Dependencies**: Run `flutter pub get`.
3.  **Run**:
    ```bash
    flutter run -d windows
    ```
    _Note: Ensure you have Visual Studio (C++) installed for Windows desktop development support._

## Tech Stack

- **Flutter & Dart**: Core framework.
- **flutter_bloc**: State management.
- **sqflite_common_ffi**: Local database (Windows support).
- **dio**: Network requests.
- **cached_network_image**: Image caching.
- **google_fonts**: Typography.
