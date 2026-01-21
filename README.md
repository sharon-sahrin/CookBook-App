# CookBook 🍳

A modern Flutter application for sharing, discovering, and managing recipes with community collaboration features.

---

## Overview

CookBook is a cross-platform recipe management and sharing application built with Flutter.

It allows users to create, edit, and share recipes with the community.

The app includes features for recipe discovery, user authentication, recipe categorization, and admin moderation capabilities.

---

## Features

### 👤 User Features

* **User Authentication**
  Secure login and registration via Supabase

* **Recipe Management**
  Create, edit, and delete your own recipes

* **Browse Recipes**
  Discover recipes shared by the community

* **Search & Filter**
  Find recipes by title and filter by categories (Breakfast, Lunch, Dinner)

* **Recipe Details**
  View complete recipe information including ingredients and cooking steps

* **User Profile**
  Manage your profile and view your recipes

---

### 🛠 Admin Features

* **Admin Dashboard**
  Monitor and moderate community recipes

* **Pending Reviews**
  Review and approve or reject user-submitted recipes

* **User Management**
  Manage community members and their contributions

---

### 🎨 Design & UX

* **Material Design 3**
  Modern, responsive UI following latest design standards

* **Staggered Grid Layout**
  Visually appealing recipe card display

* **Google Fonts Integration**
  Custom typography using the Outfit font family

* **Cross-Platform Support**
  Android, iOS, Web, Windows, and Linux

---

## Tech Stack

### Frontend

* **Flutter 3.9.2+** – Cross-platform UI framework
* **Provider** – State management
* **Dart** – Programming language

---

### Backend & Services

* **Supabase** – Authentication and database
* **PostgreSQL** – Database (via Supabase)

---

### Key Dependencies

* `supabase_flutter: ^2.8.3`
* `provider: ^6.1.2`
* `google_fonts: ^6.2.1`
* `flutter_staggered_grid_view: ^0.7.0`
* `intl: ^0.20.2`
* `shared_preferences: ^2.5.4`

---

## Project Structure

```
CookBook/
├── lib/
│   ├── main.dart
│   ├── constants.dart
│   ├── recipe.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── recipe_provider.dart
│   └── screens/
│       ├── auth_gate.dart
│       ├── login_screen.dart
│       ├── home_screen.dart
│       ├── profile_screen.dart
│       ├── recipe_detail_screen.dart
│       ├── add_edit_recipe_screen.dart
│       ├── nav_screen.dart
│       └── admin_dashboard_screen.dart
├── android/
├── ios/
├── windows/
├── macos/
├── linux/
├── web/
├── test/
├── build/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

* Flutter SDK 3.9.2 or higher
* Dart SDK (included with Flutter)
* Supabase account

---

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd cookbook_project
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Supabase credentials**

Update `lib/constants.dart`:

```dart
static const String supabaseUrl = 'your-supabase-url';
static const String supabaseAnonKey = 'your-anon-key';
```

4. **Run the application**

```bash
flutter run
```

---

## Database Setup

### Tables

#### recipes

Fields:

* id
* title
* description
* ingredients
* steps
* category
* icon
* user_id
* status
* created_at
* author_name

Statuses:

* `draft`
* `pending_review`
* `published`
* `rejected`

---

#### profiles

User profile information (created automatically by Supabase Auth)

---

## Recipe Model

The `Recipe` class contains:

* id
* title
* description
* ingredients
* steps
* category
* icon
* userId
* status
* createdAt
* authorName

---

## Development

### Run Tests

```bash
flutter test
```

---

### Build for Production

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# Linux
flutter build linux
```

---

## State Management

### AuthProvider

* Login & logout
* Session management
* Authentication state tracking

---

### RecipeProvider

* Load recipes
* Search and filter
* Create, edit, delete recipes
* Admin moderation

---

## Color Scheme

* **Primary**: Orange
* **Secondary**: Orange Accent
* **Material 3 Seed Color**: Orange

---

## Contributing

Pull requests are welcome.

---

## Support

Open an issue in the repository for support.

---

**CookBook** 🍽️
Share Your Culinary Creations!

