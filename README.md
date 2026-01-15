# PantryPal

PantryPal is a smart pantry/kitchen inventory management application built with Flutter. It helps users reduce food waste by tracking expiry dates, recommending recipes based on available ingredients, and managing smart grocery lists.

## Features

### 🏠 Dashboard

- **Pantry Overview**: Quick stats showing Total Items, Low Stock, Expiring Soon, and Fresh Items
- **Clickable Stat Cards**: Navigate directly to filtered inventory views
- **Expiring Soon Alert**: Visual warning with category images for items expiring within 3 days
- **Quick Actions**: Fast navigation to Add Item, Grocery List, and Recipes

### 📦 Inventory Management

- **FIFO Sorting**: Items sorted by expiry date (First-In-First-Out)
- **Color-Coded Indicators**:
  - 🟢 Green = Safe (>6 days)
  - 🟡 Yellow = Warning (3-6 days)
  - 🔴 Red = Critical (<3 days)
  - ⚪ Grey = Expired
- **Smart Entry**: Category-based auto-suggest expiry dates
- **Edit & Delete**: Full CRUD operations with confirmation dialogs
- **Category Images**: Visual category icons for easy identification

### 🍳 Recipe Generator

- **Ingredient Matching**: Find recipes using pantry items (powered by TheMealDB API)
- **Search Functionality**: Manual recipe search
- **Detailed Instructions**: Step-by-step cooking instructions
- **YouTube Integration**: Direct links to video tutorials

### 🛒 Smart Grocery List

- **Auto-Suggestions**: Based on low stock items (quantity ≤ 2)
- **Category Organization**: Items grouped by category
- **Check/Uncheck**: Track progress while shopping
- **Shopping History**: Reuse completed lists (auto-deleted after 7 days)

### 👤 Profile & Settings

- **Personal Information**: View and manage user profile
- **Theme Toggle**: Light/Dark mode support
- **Secure Session**: Persistent login with session management

## Architecture

The application follows **MVVM (Model-View-ViewModel)** pattern implemented with **BLoC (Business Logic Component)**.

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                             │
│  Screens (Dashboard, Inventory, Recipes, Grocery, Profile)  │
└─────────────────────────────────────────────────────────────┘
                              ↓↑
┌─────────────────────────────────────────────────────────────┐
│                       LOGIC LAYER                           │
│  BLoCs (Auth, Inventory, Recipe, Shopping, Settings, User)  │
└─────────────────────────────────────────────────────────────┘
                              ↓↑
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│  Repositories → Database (SQLite) / API (TheMealDB)         │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── main.dart                  # App Entry Point & Providers
├── core/
│   ├── theme/                 # App Theme (Colors, Typography)
│   └── utils/                 # Date Helpers, Number Helpers
├── data/
│   ├── models/                # Data Models (InventoryItem, ShoppingList, etc.)
│   ├── database/              # SQLite Helper & Schema
│   ├── content/               # API Providers (TheMealDB)
│   └── repositories/          # Data Abstraction Layer
├── logic/
│   ├── auth/                  # Authentication BLoC
│   ├── inventory/             # Inventory BLoC
│   ├── recipe/                # Recipe BLoC
│   ├── shopping/              # Shopping List BLoC
│   ├── settings/              # Settings BLoC
│   └── user/                  # User Profile BLoC
└── ui/
    ├── screens/               # All App Screens
    └── widgets/               # Reusable Widgets
```

## Setup & Running

### Prerequisites

- Flutter SDK 3.7.2+
- Dart SDK
- Visual Studio (C++) for Windows desktop

### Installation

```bash
# Clone repository
git clone <repository-url>
cd pantry_pal

# Install dependencies
flutter pub get

# Run on desired platform
flutter run -d windows    # Windows
flutter run -d chrome      # Web Browser
flutter run -d android     # Android Device/Emulator
```

## Tech Stack

| Technology                   | Purpose                      |
| ---------------------------- | ---------------------------- |
| Flutter & Dart               | Core framework               |
| flutter_bloc                 | State management             |
| sqflite / sqflite_common_ffi | Local SQLite database        |
| dio                          | HTTP client for API          |
| cached_network_image         | Image caching                |
| google_fonts                 | Plus Jakarta Sans typography |
| shared_preferences           | Key-value storage            |
| url_launcher                 | External URL handling        |

## Database Schema

- **inventory** - Pantry items with expiry tracking
- **shopping_lists** - Shopping list metadata
- **shopping_list** - Individual shopping items
- **user_profile** - User accounts
- **active_session** - Login session management

## Cross-Platform Support

| Platform          | Status       |
| ----------------- | ------------ |
| Windows Desktop   | ✅ Supported |
| Web (Chrome/Edge) | ✅ Supported |
| Android           | ✅ Supported |
| iOS               | ✅ Supported |
| Linux             | ✅ Supported |
| macOS             | ✅ Supported |

## Screenshots

_Available in `/docs/screenshots/`_

---

**Version:** 1.0.0  
**Last Updated:** January 2026
