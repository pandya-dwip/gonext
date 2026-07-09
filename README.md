# 📍 GoNext

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Database: Hive](https://img.shields.io/badge/Database-Hive%20CE-FF6B6B?logo=hive&logoColor=white)](#offline-storage)
[![Platform Support](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-lightgrey)](#requirements)

> **Never wonder where to go next again.**

GoNext is a modern, privacy-focused, offline-first Flutter application designed to help you build, organize, and catalog a personal registry of your favorite spots. Whether it is a cozy restaurant you want to try, a boutique streetwear store, or a scenic travel viewpoint, GoNext ensures you always have your custom curated collection right in your pocket.

No accounts. No trackers. No cloud syncing latency. Your personal diary of places remains completely on your device.

---

## 📖 Table of Contents

- [✨ Key Features](#-key-features)
- [🛠️ Tech Stack](#%EF%B8%8F-tech-stack)
- [📦 Directory Structure](#-directory-structure)
- [⚙️ Design Philosophy](#%EF%B8%8F-design-philosophy)
- [🚀 Installation & Setup](#-installation--setup)
- [📋 System Requirements](#-system-requirements)
- [🖼️ Screenshots](#%EF%B8%8F-screenshots)
- [📈 Current Status & Roadmap](#-current-status--roadmap)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Key Features

### 🎛️ Unified Dashboard
* **Dynamic Search**: Instantly look up saved dining spots, clothing stores, and viewpoints from home with in-memory matching.
* **In-Memory Grouped Search**: Grouped results are organized by directory category with matching text highlighting on names, cuisines, and addresses.
* **Overview Metrics**: Clear numerical counts displaying total Saved, Visited, and Added This Month counts to track your exploration habits.
* **Visual Previews**: Clean horizontal layout galleries showcasing recently added spots and an interactive 2x2 grid preview of your wishlist.

### 🍽️ Restaurants Directory
* **Cuisine Catalogs**: Categorize dining spaces with a wide selection of cuisines (e.g. Indian, Chinese, Italian, Continental, Fast Food, etc.).
* **Budget Metrics**: Track ranges from Budget Friendly, Moderate, Premium, to Luxury.
* **CRUD & Ratings**: Complete lifecycle management backed by star ratings and interactive visited indicators.

### 👗 Clothing Stores
* **Retail Classification**: Save designer boutiques, vintage thrift stores, shopping malls, and streetwear ateliers.
* **Budget & Lifestyle**: Map local retail choices with budget estimates to make shopping runs easier.

### 🏞️ Places to Visit
* **Travel Landmarks**: Log heritage sites, state parks, beaches, viewpoints, and museums.
* **Seasonal Planning**: Tag best season times (e.g. Winter, Monsoon, Summer) and entry fees (Free/Paid ticket pricing).

### 🗺️ Location & Maps Integration
* **Current Coordinates**: Instantly fetch precise device location pins via Geolocator.
* **Map Picker**: Pinpoint and fine-tune markers on an interactive Google Map.
* **Reverse Geocoding**: Automatically convert coordinates into readable street addresses.
* **Advanced Coordinates Input**: Manually specify and edit latitude and longitude.
* **Copy & Navigate**: One-tap copying of formatted addresses and coordinates, and quick links to open locations directly in the native Google Maps app.

### 📸 Media Integration
* **Photo Coverage**: Assign cover photos using the device camera, gallery, or default fallback assets.
* **Caching**: Decoupled asset and file storage paths for fast list renderings.

---

## 🛠️ Tech Stack

| Package / Framework | Version Category | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `>=3.22` | Core cross-platform UI rendering engine |
| **Dart** | `>=3.4` | Application programming language |
| **Flutter Riverpod** | `State Management` | Uni-directional data flow, modular state overrides, and reactive queries |
| **Go Router** | `Routing` | Declarative, type-safe path-based navigation |
| **Hive CE** | `Database` | High-performance, offline-first NoSQL key-value store |
| **Google Maps Flutter** | `Mapping` | Interactive satellite, terrain, and road maps |
| **Geolocator** | `Geolocator` | Real-time GPS location coordinates retrieval |
| **Geocoding** | `Geocoding` | Reverse geocoding of coordinates to addresses |
| **Google Fonts** | `Typography` | Dynamic load of premium Outfit, Inter, and modern sans-serif fonts |
| **Flex Color Scheme** | `Theming` | Premium design layouts, custom HSL color palettes, and widgets properties |

---

## 📦 Directory Structure

The project strictly follows a **modular architecture** pattern, grouping files by feature domain rather than purely technical layers.

```text
lib/
├── app/                      # Application wrappers & global configurations
│   ├── app.dart              # Core MaterialApp setup
│   └── app_router.dart       # Declared GoRouter path parameters
├── core/                     # Core system configurations & design tokens
│   ├── constants/            # AppColors, AppSizes, and system strings
│   ├── theme/                # Typographies, border styles, and button decorations
│   └── utils/                # Date parsers and clipboard helpers
├── modules/                  # Feature Modules
│   ├── dashboard/            # Home metrics, search interfaces, and previews
│   ├── places/               # Restaurants, clothing stores, and visits directories
│   └── settings/             # Offline data purge and app info controls
├── shared/                   # Reusable cross-feature components
│   ├── components/           # GNCard, GNChip, GNButton, GNEmptyState, and HighlightedText
│   └── providers/            # Shared device location and state providers
└── main.dart                 # Application entry point & Hive initialization
```

---

## ⚙️ Design Philosophy

* **Offline First**: The application must remain fully functional without active cellular or internet connectivity. All edits are stored instantly in local Hive boxes.
* **Privacy Focused**: No clouds, no servers, and no advertising trackers. Your data belongs exclusively on your local device storage.
* **Minimal & Purposeful**: A clutter-free UI focusing on typography and clear visual cues instead of complex options.
* **Tactile Aesthetics**: Custom glassmorphism-inspired cards, smooth micro-interactions, distinct category status colors, and modern layout cards (4:3 dining cards, 4:5 retail clothing cards, and 16:9 scenic postcard grids).

---

## 🚀 Installation & Setup

Ensure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install) on your development environment.

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/gonext.git
   cd gonext
   ```

2. **Fetch Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API Key (Optional)**
   - Create a Google Maps API Key via the Google Cloud Console.
   - For Android, insert your key inside `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
     ```
   - For iOS, configure it inside `ios/Runner/AppDelegate.swift`.
   - *Note: If no API key is set, the app will automatically fall back to an elegant mock drawing layout with external mapping options.*

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 📋 System Requirements

* **Development SDK**: Flutter `3.22.x` / Dart `3.4.x` or higher
* **Android**: API Level `21` (Lollipop) or newer
* **iOS**: Deployment Target `iOS 13.0` or newer
* **IDEs Supported**: Visual Studio Code, Android Studio, IntelliJ IDEA

---

## 🖼️ Screenshots

| Home Dashboard | Restaurant Details | Places Grid |
|:---:|:---:|:---:|
| *[Coming Soon]* | *[Coming Soon]* | *[Coming Soon]* |

| Add Clothing Store | Settings | Wishlist Map |
|:---:|:---:|:---:|
| *[Coming Soon]* | *[Coming Soon]* | *[Coming Soon]* |

---

## 📈 Current Status & Roadmap

### Current Status
* **Version**: `0.8.0-dev`
* Core directory categories (Restaurants, Boutiques, viewpoint places) fully functional.
* Local persistent storage with Hive boxes configured.
* Search with text-matching highlights and horizontal multi-select filters complete.

### Roadmap & Planned Features
- [ ] **Custom Collections**: Create folders and custom category lists (e.g. "Weekend Getaway").
- [ ] **Backup & Restore**: Export local databases to encrypted JSON files for manual transfers.
- [ ] **Photo Gallery**: Support saving multiple lifestyle shots per location.
- [ ] **Automatic Dark Mode**: Follow system brightness toggles.
- [ ] **Advanced Analytics**: Generate graphs of your favorite cuisines and categories.
- [ ] **Animations**: Add slide-in transitions and list deletion fade-outs.
- [ ] **Export to CSV**: Export directories for sharing tables with friends.

---

## 🤝 Contributing

This is currently a personal project built to help organize location diaries. Future contributions, bug reports, and features proposals are welcome once the public open-source release is finalized.

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more details.

---

Developed with ❤️ using Flutter.
