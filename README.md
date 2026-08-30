# Smart Cabinet - Demo Application

A Flutter-based demonstration application for inventory management. This is a demo app showcasing a smart cabinet interface for managing personal or organizational items.

## 📋 Overview

Smart Cabinet is a demonstration app designed to help users manage their personal or organizational items with ease. The app uses modern technologies including:

- **Flutter** for cross-platform mobile development (Android)
- **Firebase** for authentication and real-time database management
- **AI/ML Integration** with Google Gemini for intelligent item categorization and recommendations
- **Local Storage** using Hive for offline-first functionality
- **Push Notifications** for timely alerts and reminders

## 🎯 Key Features

- **Smart Inventory Management**: Add, organize, and categorize items in your cabinet
- **AI-Powered Categorization**: Automatic item classification using Google Gemini AI
- **Cloud Synchronization**: Real-time sync across devices via Firebase Firestore
- **User Authentication**: Secure sign-up and login with Firebase Authentication
- **Local Notifications**: Push notifications for item expiry, low stock, or custom reminders
- **Offline Support**: Full functionality with offline access using Hive local database
- **Android Only**: Optimized for Android platform

## 🛠️ Technology Stack

### Frontend
- **Dart**: Primary programming language (88.6% of codebase)
- **Flutter**: Cross-platform UI framework
- **Hive**: Fast local database for offline storage

### Backend & Services
- **Firebase**: Cloud infrastructure provider
  - Firebase Authentication
  - Cloud Firestore (Real-time database)
  - Firebase Core
- **Google Gemini API**: AI-powered item categorization and smart suggestions

### Build System
- **CMake**: Build system (5.3%)
- **C++**: Performance-critical operations (3.3%)
- **C**: Low-level utilities (0.4%)

## 📦 Dependencies

Key packages and versions:

```yaml
flutter: SDK dependency
firebase_core: ^4.6.0
firebase_auth: ^6.3.0
cloud_firestore: ^6.2.0
google_generative_ai: ^0.4.7
hive: ^2.2.3 & hive_flutter: ^1.1.0
flutter_local_notifications: ^21.0.0
http: ^1.2.0
flutter_dotenv: ^5.1.0
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.11.1 or higher
- Dart 3.11.1 or higher
- A Firebase project
- Google Gemini API key (optional for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hueiqi/project-smart-cabinet.git
   cd project-smart-cabinet/smart_cabinet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

3. **Configure environment variables**
   - Create a `.env` file in the project root
   - Add your Firebase configuration and API keys:
     ```
     FIREBASE_API_KEY=your_key
     GOOGLE_GEMINI_API_KEY=your_key
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Project Structure

```
smart_cabinet/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── screens/                  # UI screens
│   ├── widgets/                  # Reusable widgets
│   ├── models/                   # Data models
│   ├── services/                 # Business logic & API services
│   │   ├── firebase_service.dart
│   │   ├── gemini_service.dart
│   │   └── notification_service.dart
│   └── utils/                    # Utility functions
├── pubspec.yaml                  # Dart dependencies
├── pubspec.lock                  # Locked dependency versions
└── android/                       # Android-specific code
```

## 🔐 Authentication & Security

- **Firebase Authentication**: Handles secure user registration and login
- **Environment Variables**: Sensitive credentials stored in `.env` file
- **Hive Encryption**: Local data stored securely on device

## 🤖 AI Integration

The Smart Cabinet uses **Google Gemini AI** for:
- Automatic item classification
- Smart recommendations based on cabinet contents
- Natural language queries for item searching
- Expiry prediction and waste reduction suggestions

## 📲 Notifications

Push notifications powered by `flutter_local_notifications`:
- Item expiry reminders
- Low inventory alerts
- Custom user reminders
- Timezone-aware scheduling

## 📊 Local Database (Hive)

- **Offline-first architecture**: Full app functionality without internet
- **Fast key-value storage**: Optimized for mobile devices
- **Type-safe**: Dart-generated adapters for type safety

## 🔄 Cloud Synchronization

Data automatically syncs across devices through:
- **Cloud Firestore**: Real-time database
- **Firebase Authentication**: User-specific data isolation
- **Conflict Resolution**: Smart merging of offline changes

## 🧪 Development

### Build Runner for Code Generation
```bash
flutter pub run build_runner build      # One-time build
flutter pub run build_runner watch      # Watch for changes
```

### Running on Android
```bash
flutter run -d android                  # Android
```

## 📝 License

This project is currently unlicensed. See the repository for more details.

## 👤 Author

**Hueiqi** - [GitHub Profile](https://github.com/Hueiqi)

## 📅 Project Info

- **Created**: April 12, 2026
- **Last Updated**: August 26, 2026
- **Repository**: [project-smart-cabinet](https://github.com/Hueiqi/project-smart-cabinet)
- **Visibility**: Public

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📞 Support

For issues, feature requests, or questions, please open an [issue](https://github.com/Hueiqi/project-smart-cabinet/issues) on GitHub.

---

**Note**: This project is a demo application and is actively under development. Features and documentation may be updated regularly.
