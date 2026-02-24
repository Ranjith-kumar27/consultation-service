# Doctor Consultation & Service Booking Application

A comprehensive, cross-platform health consultation booking system built with Flutter and Firebase. The application follows **Clean Architecture** principles and provides dedicated interfaces for Patients, Doctors, and Administrators.

## 🚀 Features

### For Patients
- **Search & Filter**: Find doctors by name or specialization.
- **Detailed Profiles**: View doctor qualifications, availability, and ratings.
- **Easy Booking**: Select time slots and book appointments seamlessly.
- **Booking History**: Track past and upcoming consultations.
- **Real-time Chat**: One-to-one communication with doctors.

### For Doctors
- **Dashboard**: Track daily earnings, pending requests, and upcoming appointments.
- **Availability Management**: Toggle online status and manage consultation time slots.
- **Booking Management**: Accept or reject pending appointment requests.
- **Earnings Summary**: View detailed financial analytics.
- **Video Calls**: Integrated high-quality video consultations via Agora.

### For Administrators
- **Verification Flow**: Review and approve doctor registration requests.
- **User Management**: Block/Unblock users to ensure platform safety.
- **Full Oversight**: View all platform-wide bookings and transaction totals.

## 🛠 Tech Stack

- **Frontend**: Flutter (3.10.8+)
- **Backend/Database**: Firebase (Core, Auth, Firestore)
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: GetIt
- **Routing**: GoRouter
- **Real-time Communication**: Firestore Streams (Chat), Agora RTC Engine (Video Calls)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **UI Styling**: Custom Sage Green Medical Theme

## 🏗 Project Structure

The project adheres to **Clean Architecture** (Domain, Data, Presentation layers):

```
lib/
├── core/               # Shared utilities, constants, theme, and network config
├── features/           # Feature-driven modules
│   ├── auth/           # Login, Patient/Doctor registration
│   ├── patient/        # Dashboard, Search, Booking flow
│   ├── doctor/         # Dashboard, Slot management, Earnings
│   ├── admin/          # Approval flow, User control, Financials
│   ├── chat/           # Real-time messaging
│   ├── call/           # Video consultation (Agora)
│   └── notification/   # FCM integration
└── main.dart           # Application entry point
```

## ⚙️ Setup & Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Ranjith-kumar27/consultation-service.git
    cd consultation-service
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**:
    - Create a project on [Firebase Console](https://console.firebase.google.com/).
    - Add Android/iOS applications and download `google-services.json` / `GoogleService-Info.plist`.
    - Enable Authentication (Email/Password), Firestore, and Cloud Messaging.

4.  **Agora Setup**:
    - Obtain an App ID from the [Agora Console](https://console.agora.io/).
    - Paste your App ID in `lib/features/call/presentation/pages/call_page.dart`.

5.  **Run the application**:
    ```bash
    flutter run
    ```

## 🎨 Theme

The application features a modern **Sage Green** medical theme (#5E8B7E) designed for visual comfort and trust.

---
Developed with ❤️ by the Ranjith Kumar R - AppMagician.
