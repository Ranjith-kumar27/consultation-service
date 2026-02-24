# DOCTOR - Consultation & Booking App

A comprehensive Flutter application designed to bridge the gap between patients and doctors by facilitating seamless consultations, appointment bookings, direct chat, and real-time video calls. Built for scale, security, and a premium user experience.

---

## 🏗 Architecture

The project follows the principles of **Clean Architecture** to maintain a scalable, testable, and maintainable codebase.

The architecture is divided into three primary layers, implemented on a per-feature basis to keep domains fully isolated:

1. **Presentation Layer**: Handles the UI and User Input. It uses BLoC (Business Logic Component) for robust state management.
    - **UI**: Flutter Widgets (Pages & Components).
    - **State Management**: Events and States mapped via `flutter_bloc`.
    - **Logic**: Handles UI rebuilds efficiently and listens to Bloc states.

2. **Domain Layer**: The core of the application that enforces business rules. It contains zero dependencies on external libraries (like Firebase or HTTP).
    - **Entities**: Core data structures (e.g., `UserEntity`, `AppointmentEntity`).
    - **Repositories (Contracts)**: Abstract classes defining the data operations expected to be implemented.
    - **Use Cases**: Specific actions/business logic the system can perform (e.g., `BookAppointmentUseCase`, `SendMessageUseCase`).

3. **Data Layer**: Responsible for retrieving or pushing data out of the system.
    - **Models**: Extensions of Entities with `fromJson` and `toJson` methods for serialization.
    - **Data Sources**: Implementations connecting directly to external services (e.g., Firebase, REST APIs, Local Storage).
    - **Repositories (Implementations)**: Concrete implementations of the Domain Layer Repository Contracts, acting as the single source of truth for Use Cases.

This setup ensures that replacing a database or an API endpoint only affects the Data Layer, leaving the core business logic (Domain) entirely intact.

---

## 🗄 Database Schema (Cloud Firestore)

The application utilizes Firebase Cloud Firestore, structured into the following primary collections:

### 1. `users`
Stores all account data. The distinction between roles is maintained using the `role` field.
- **Document ID**: `uid` (Firebase Auth UID)
- **Fields**:
  - `uid` (String)
  - `name` (String)
  - `email` (String)
  - `role` (String: `"patient"` | `"doctor"`)
  - `fcmToken` (String) - _For push notifications_
  - `createdAt` (Timestamp)
  - **Doctor Only Fields**:
    - `specialization` (String)
    - `district` (String) - _Regionalization (Tamil Nadu)_
    - `consultationFee` (Number)
    - `isAvailable` (Boolean)

### 2. `appointments`
Manages all booking records between Patients and Doctors.
- **Document ID**: Auto-generated
- **Fields**:
  - `id` (String)
  - `patientId` (String - Reference to `users`)
  - `doctorId` (String - Reference to `users`)
  - `patientName` (String)
  - `doctorName` (String)
  - `date` (Timestamp)
  - `timeSlot` (String)
  - `status` (String: `"pending"`, `"confirmed"`, `"completed"`, `"cancelled"`)
  - `createdAt` (Timestamp)

### 3. `chats`
Root collection for the messaging system.
- **Document ID**: Combined User IDs (e.g., `uid1_uid2` for a 1-on-1 chat room)
- **Fields**:
  - `participants` (Array of Strings [uid1, uid2])
  - `lastMessage` (String)
  - `lastMessageTime` (Timestamp)
- **Sub-collection**: `messages`
  - **Document ID**: Auto-generated
  - **Fields**:
    - `senderId` (String)
    - `text` (String)
    - `timestamp` (Timestamp)
    - `isRead` (Boolean)

---

## 📦 Third-Party Packages

The success and rich features of this application rely heavily on the following robust Flutter and Dart packages:

### Core Framework & State Management
* **`flutter_bloc`**: Predictable and reliable State Management.
* **`get_it`**: Service locator for clean Dependency Injection.
* **`equatable`**: Simplifying object comparison, crucial for Bloc states.

### Backend & Services (Firebase)
* **`firebase_core`**: The essential Firebase initialization plugin.
* **`firebase_auth`**: Seamless user authentication.
* **`cloud_firestore`**: Scalable NoSQL real-time database.
* **`firebase_messaging`**: For Firebase Cloud Messaging (Push Notifications).

### Calling & Notifications
* **`agora_rtc_engine`**: High-quality, real-time video and audio calling.
* **`permission_handler`**: Cleanly requesting hardware permissions (Camera, Mic).
* **`flutter_local_notifications`**: Displaying local popups when real push notifications arrive.
* **`googleapis_auth`**: Essential for interacting securely with Firebase Cloud Messaging directly.

### UI & UX Enhancements
* **`go_router`**: Declarative routing system for complex app navigation.
* **`google_fonts`**: Modern typography, directly imported.
* **`shimmer`**: Skeleton loaders for a premium waiting experience.
* **`lottie`**: Beautiful, lightweight animations for empty states and feedback.
* **`cached_network_image`**: Performant image loading and caching.
* **`intl`**: Comprehensive date and currency formatting.

---

## 🚀 Setup Instructions

Follow these steps to get the application running locally:

### 1. Prerequisites
- **Flutter SDK**: Ensure you have Flutter installed (`v3.10.8` or higher). Run `flutter doctor` to check.
- **IDE**: VS Code or Android Studio with Flutter plugins.
- **Firebase Account**: Required for Database and Authentication configuration.
- **Agora Account**: Required for configuring real-time video calling.

### 2. Environment Configuration

#### Agora Configuration
1. Open `lib/core/constants/app_constants.dart`.
2. Locate the static property `agoraAppId`.
3. Replace the placeholder with your active Agora App ID.

### 3. Firebase Setup
**Note**: This project utilizes Firebase Native credentials instead of `flutterfire_cli` generated files.

#### For Android
1. Go to the Firebase Console -> Project Settings -> General.
2. Add an Android App with the application ID `com.consultation.consultation_service_app`.
3. Download the `google-services.json` file.
4. Place the file inside `android/app/`.

#### For iOS
1. Add an iOS App in the Firebase console.
2. Download `GoogleService-Info.plist`.
3. Open `Runner.xcworkspace` in Xcode.
4. Drag and drop `GoogleService-Info.plist` completely into your Runner project folder via Xcode.

### 4. Running the App
Run the following commands in the root of the project direction to clean, install dependencies, and launch:

```bash
flutter clean
flutter pub get
flutter run
```

_For testing video calls, you must deploy the application to two physical devices (Simulators lack camera support)._
