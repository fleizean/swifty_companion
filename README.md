# 🚀 Peer42

[![Build APK and Reminders](https://github.com/fleizean/swifty_companion/actions/workflows/ci.yml/badge.svg)](https://github.com/fleizean/swifty_companion/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A high-performance, premium Flutter application designed specifically for **42 Network** students. Experience your 42 profile like never before with real-time stats, hierarchical project tracking, and a sleek, coalition-themed UI.

---

## ✨ Key Features

- **🎯 Smart Profile Dashboard:** Instantly view your level, wallet (altems), evaluation points, and active campus location.
- **📁 Hierarchical Projects:** An advanced project list that groups sub-projects (like evaluations) under their parents. No more cluttered lists!
- **🔍 Intelligent Search:** Find peers instantly with a debounced search and persistent recent history.
- **🎨 Dynamic RPG UI:** Experience level progression with custom-styled progress bars and dynamic coalition watermarks.
- **🔄 Multi-Cursus Support:** Seamlessly switch between your core cursus, piscines, and other programs with one tap.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Channel Stable)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Networking:** [Dio](https://pub.dev/packages/dio) with custom interceptors for OAuth2.
- **Architecture:** Clean Layered Architecture (Data, Presentation, Core).
- **Typography:** Google Fonts (Lilita One, Hanken Grotesk, JetBrains Mono).

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- 42 API Credentials (UID & Secret)

### Setup
1. **Clone the repository:**
   ```bash
   git clone https://github.com/fleizean/swifty_companion.git
   cd peer42
   ```

2. **Configure Environment:**
   Create a `.env` file in the root directory:
   ```env
   CLIENT_ID=your_uid_here
   CLIENT_SECRET=your_secret_here
   REDIRECT_URI=peer42://oauth/callback
   ```

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```