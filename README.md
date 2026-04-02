<div align="center">

# 🎓 StudyApp

### Peer-to-Peer Tutoring Marketplace

*Connect with expert tutors. Learn on your terms.*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)](https://nestjs.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Prisma](https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white)](https://www.prisma.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)

[![GitHub Stars](https://img.shields.io/github/stars/hiyokun-d/study-app?style=social)](https://github.com/hiyokun-d/study-app/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hiyokun-d/study-app?style=social)](https://github.com/hiyokun-d/study-app/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/hiyokun-d/study-app)](https://github.com/hiyokun-d/study-app/issues)
[![GitHub PRs](https://img.shields.io/github/issues-pr/hiyokun-d/study-app)](https://github.com/hiyokun-d/study-app/pulls)

</div>

---

## 📖 What is StudyApp?

**StudyApp** is a modern, decoupled educational platform designed to connect students directly with expert tutors. Instead of rigid, one-size-fits-all curriculums, StudyApp puts the learner in control — choose **what** to learn, **who** to learn from, and **when** to learn it.

> "Education is not the filling of a pail, but the lighting of a fire." — W.B. Yeats

<br/>

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **JWT Authentication** | Secure login & registration with token-based auth |
| 🔑 **Google Sign-In** | One-tap OAuth login via Google |
| 👨‍🏫 **Tutor Profiles** | Browse and connect with expert tutors |
| 🎓 **Student Dashboard** | Track learning progress and upcoming sessions |
| 💬 **Real-time Chat** | Direct messaging between students and tutors |
| 📦 **Subscription Plans** | Flexible plans for different learning needs |
| 📱 **Cross-platform** | Flutter-powered: runs on Android, iOS, and Web |

<br/>

## 🛠 Tech Stack

### Frontend — Flutter (Dart)

| Tool | Purpose |
|---|---|
| **Flutter 3.5+** | Cross-platform UI framework |
| **Google Fonts** | Custom typography |
| **Font Awesome Flutter** | Icon library |
| **HTTP** | REST API communication |
| **Google Sign-In** | OAuth authentication |
| **Material 3** | Design system |

### Backend — NestJS (TypeScript)

| Tool | Purpose |
|---|---|
| **NestJS** | Modular Node.js framework |
| **Prisma ORM** | Type-safe database access & migrations |
| **PostgreSQL** | Relational database (hosted on Supabase) |
| **JWT** | Stateless authentication tokens |
| **Jest** | Unit & end-to-end testing |

<br/>

## 🏗 Architecture

```
StudyApp
├── Flutter Frontend (Mobile / Web)
│     └── Communicates via REST API ──────────────────┐
│                                                      ▼
└── NestJS Backend                           ┌─────────────────┐
      ├── Auth Module (JWT + Google OAuth)   │   PostgreSQL DB  │
      ├── User Module                        │  (via Supabase)  │
      ├── Student Module                     └─────────────────┘
      ├── Teacher Module
      ├── Chat Module
      └── Subscription Module
```

**Frontend Architecture:** Feature-first modular design. Each feature (auth, chat, student, teacher) is self-contained with its own screens.

**Backend Architecture:** Domain-driven NestJS modules with Prisma handling all database operations. Each domain (auth, user, teacher, student, chat, subscription) is fully isolated.

<br/>

## 📂 Project Structure

```
study-app/
│
├── lib/                          # Flutter Frontend
│   ├── features/                 # Feature modules
│   │   ├── auth/                 #   Login & registration screens
│   │   ├── chat/                 #   Messaging screens
│   │   ├── student/              #   Student dashboard & views
│   │   └── teacher/              #   Tutor profile & views
│   ├── core/                     # Shared utilities
│   │   ├── constants/            #   App-wide constants
│   │   ├── themes/               #   Material 3 theme config
│   │   └── widgets/              #   Reusable UI components
│   ├── models/                   # Shared data models (DTOs)
│   └── routes/                   # App navigation & routing
│
├── _server/                      # NestJS Backend
│   ├── src/
│   │   ├── auth/                 #   JWT auth + Google OAuth
│   │   ├── user/                 #   User management
│   │   ├── student/              #   Student-related logic
│   │   ├── teacher/              #   Teacher-related logic
│   │   ├── chat/                 #   Messaging system
│   │   ├── subscription/         #   Subscription plans
│   │   ├── prisma.service.ts     #   Database connection
│   │   └── main.ts               #   App entry point
│   └── prisma/
│       ├── schema.prisma         #   Database schema
│       └── migrations/           #   Migration history
│
├── docs.md                       # Full architectural documentation
└── pubspec.yaml                  # Flutter dependencies
```

<br/>

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.5.0`
- [Node.js](https://nodejs.org/) `v18+` & npm
- [Git](https://git-scm.com/)
- A [Supabase](https://supabase.com/) project (for the PostgreSQL database)

---

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/hiyokun-d/study-app.git
cd study-app
```

---

### 2️⃣ Frontend Setup (Flutter)

```bash
# Install Flutter dependencies
flutter pub get

# Run the app (make sure a device/emulator is running)
flutter run

# Or target a specific platform
flutter run -d chrome      # Web
flutter run -d android     # Android
```

---

### 3️⃣ Backend Setup (NestJS)

```bash
# Navigate to the server directory
cd _server

# Install Node dependencies
npm install

# Set up environment variables
cp .env.example .env
# Open .env and fill in:
#   DATABASE_URL=...   (Supabase pooled connection)
#   DIRECT_URL=...     (Supabase direct connection)
#   JWT_SECRET=...     (a long random secret)

# Generate the Prisma client
npx prisma generate

# Run database migrations
npx prisma migrate deploy

# Start the development server (hot reload)
npm run start:dev
```

The API will be available at `http://localhost:3000`.

<br/>

## 📡 API Reference

> **Base URL:** `http://localhost:3000`
> **Auth:** Protected routes require `Authorization: Bearer <access_token>` in the header.

---

### 🔐 Auth — `/auth`

#### `GET /auth`
Health check for the auth route.

```
Response 200: "You're at the right path, continue!"
```

---

#### `POST /auth/signup`
Register a new user account.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword",
  "role": "STUDENT"
}
```
> `role` must be `"STUDENT"` or `"TUTOR"`

**Response `201`:**
```json
{
  "message": "Signup successful",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "role": "STUDENT"
  }
}
```

---

#### `POST /auth/login`
Log in with email and password.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response `200`:**
```json
{
  "message": "Login successful",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "role": "STUDENT"
  }
}
```

---

#### `POST /auth/google`
Sign in or register via Google OAuth.

**Request Body:**
```json
{
  "idToken": "google-id-token-from-client",
  "role": "STUDENT"
}
```

**Response `200`:**
```json
{
  "message": "Google login successful",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@gmail.com",
    "role": "STUDENT",
    "full_name": "John Doe",
    "avatar_url": "https://..."
  }
}
```

---

### 👤 User — `/user`

#### `GET /user/tutors/all`
Returns all tutor profiles.

```
GET /user/tutors/all
Response 200: [ { ...tutorProfile }, ... ]
```

---

#### `GET /user/student`
Returns all student profiles.

```
GET /user/student
Response 200: [ { ...studentProfile }, ... ]
```

---

#### `GET /user/tutors`
Search and filter tutors.

**Query Parameters:**

| Param | Type | Description |
|---|---|---|
| `search` | `string` | Search by name or keyword |
| `subject` | `string` | Filter by subject |
| `maxPrice` | `number` | Max price per hour |

```
GET /user/tutors?search=math&subject=algebra&maxPrice=150000
Response 200: [ { ...tutorProfile }, ... ]
```

---

#### `GET /user/tutor/:id`
Get detailed profile + offers for a single tutor.

```
GET /user/tutor/uuid-here
Response 200: { ...tutorProfile, offers: [ ...tutorOffers ] }
```

---

#### `PATCH /user/update/profile` 🔒 *Auth Required*
Update the authenticated user's profile. All fields are optional.

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "full_name": "John Doe",
  "username": "john_doe",
  "bio": "Passionate math tutor with 5 years experience.",
  "avatar_url": "https://example.com/avatar.png",
  "role": "TUTOR"
}
```

**Response `200`:**
```json
{
  "message": "Profile updated",
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "full_name": "John Doe",
    "username": "john_doe",
    "bio": "Passionate math tutor with 5 years experience.",
    "avatar_url": "https://example.com/avatar.png",
    "role": "TUTOR"
  }
}
```

---

### Implementing API Calls in Flutter

The app uses a centralized service pattern. All user API calls go through `UserApiService` and all auth API calls manage state via `AuthState`.

**File structure:**
```
lib/core/services/
├── auth_state.dart        # Holds access_token, userId, role — use anywhere
└── user_api_service.dart  # Global user API methods (updateProfile, etc.)
```

#### Using `updateProfile` anywhere in the app

```dart
import 'package:myapp/core/services/user_api_service.dart';

// Call from any widget — no need to rewrite the HTTP logic
final result = await UserApiService.instance.updateProfile(
  username: 'john_doe',
  fullName: 'John Doe',
  bio: 'I love math',
  role: 'STUDENT',         // or 'TUTOR'
  avatarUrl: 'https://...', // optional
);

if (result.success) {
  final updatedUser = result.user; // Map<String, dynamic>
  print(updatedUser?['username']); // 'john_doe'
} else {
  print(result.errorMessage); // user-friendly error string
}
```

#### Using `AuthState` for the JWT token

`AuthState` is a singleton that holds the logged-in user's token and info. Set it once after login, read it anywhere.

```dart
import 'package:myapp/core/services/auth_state.dart';

// After login — store the token
AuthState.instance.setFromResponse(responseData); // pass the decoded JSON body

// Read token info anywhere
print(AuthState.instance.accessToken);
print(AuthState.instance.role); // 'STUDENT' or 'TUTOR'
print(AuthState.instance.isLoggedIn); // true / false

// Get headers for authenticated requests
final headers = AuthState.instance.authHeaders;
// → { 'Content-Type': 'application/json', 'Authorization': 'Bearer eyJ...' }

// Clear on logout
AuthState.instance.clear();
```

#### Adding a new API method

Follow this pattern when adding new endpoints to `UserApiService`:

```dart
// In lib/core/services/user_api_service.dart

Future<SomeResult> getSomething(String id) async {
  if (!AuthState.instance.isLoggedIn) {
    return SomeResult.error('Not authenticated');
  }

  try {
    final response = await http.get(
      Uri.parse('${AppConfig.API_URL}/user/something/$id'),
      headers: AuthState.instance.authHeaders,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return SomeResult.success(data);
    }
    return SomeResult.error(data['message']?.toString() ?? 'Failed');
  } catch (e) {
    return SomeResult.error('Network error: $e');
  }
}
```

<br/>

## 🧪 Testing

### Running Tests

#### Backend (NestJS)

```bash
cd _server

npm run test          # Run all unit tests
npm run test:watch    # Watch mode (re-runs on file save)
npm run test:cov      # Unit tests + coverage report
npm run test:e2e      # End-to-end tests
```

#### Frontend (Flutter)

```bash
flutter test
```

---

### Backend Test Coverage

The backend has **62 unit tests** across 5 test suites. Every service method and controller endpoint is covered. All database calls are mocked via `PrismaService` — no real DB connection needed to run tests.

#### `auth.service.spec.ts` — 18 tests

| Group | What's tested |
|---|---|
| `signUp` | Creates user, defaults role to `STUDENT`, uppercases role, hashes password (never stores plaintext), rejects duplicate email |
| `login` | Returns tokens on valid credentials, throws on unknown email, throws on wrong password, verifies against stored hash |
| `googleLogin` | Creates new user if none exists, reuses existing account, updates profile when `full_name`/`avatar_url` is missing, throws on invalid token, throws when Google payload has no email |

#### `auth.controller.spec.ts` — 8 tests

| Endpoint | What's tested |
|---|---|
| `GET /auth` | Returns path confirmation string |
| `POST /auth/signup` | Delegates to service with correct args, passes `undefined` role when omitted, returns service response |
| `POST /auth/login` | Delegates to service, propagates errors |
| `POST /auth/google` | Delegates to service with token + role, propagates errors |

#### `user.service.spec.ts` — 24 tests

| Group | What's tested |
|---|---|
| `getAllTutorProfile` | Returns list, returns empty array, selects correct fields |
| `getAllStudentProfile` | Returns list, returns empty array |
| `getTutorFilteredBy` | No filters, search query, subject filter, maxPrice filter, all filters combined, no extra fields when no filters, orders by `created_at desc` |
| `getTutorDetailProfile` | Returns tutor with active offers, only queries `is_active: true` offers, throws `404` when not found |
| `updateProfile` | Updates and returns profile, uppercases role, skips role field when not provided, sets `updated_at` timestamp, throws `400` on empty `userId`, throws `404` when user doesn't exist, supports partial updates |

#### `user.controller.spec.ts` — 12 tests

| Endpoint | What's tested |
|---|---|
| `GET /user` | Returns message and timestamp |
| `GET /user/tutors/all` | Delegates to service |
| `GET /user/student` | Delegates to service |
| `GET /user/tutors` | Passes all query params, parses `maxPrice` string → number, passes `undefined` when params absent |
| `GET /user/tutor/:id` | Returns tutor detail, propagates `404` |
| `PATCH /user/update/profile` | Resolves `userId` from `req.user.userId`, falls back to `.sub`, falls back to `.id`, throws `401` when all absent, propagates service errors |

---

### Test Configuration

Tests use `@nestjs/testing` with Jest + ts-jest. The jest config in `package.json` includes two key settings that make it work with this project:

```json
"moduleNameMapper": {
  "^src/(.*)$": "<rootDir>/$1",
  "^(\\.{1,2}/.*)\\.js$": "$1"
}
```

- `src/` alias maps to the `rootDir` so absolute imports resolve correctly
- `.js` extension stripping handles the ESM-style imports in the generated Prisma client

<br/>

## 👥 Contributors

Thanks to these amazing people who built StudyApp together!

<br/>

<div align="center">

[![Contributors](https://contrib.rocks/image?repo=hiyokun-d/study-app)](https://github.com/hiyokun-d/study-app/graphs/contributors)

</div>

> Want to contribute? Read the [collaboration guide](#-github-collaboration-guide) below!

<br/>

## 🤝 GitHub Collaboration Guide

To keep code quality high and avoid conflicts, everyone follows this workflow:

### The Golden Rule

> **Never push directly to `main`.** All changes must go through a Feature Branch + Pull Request.

---

### Branching Strategy

| Branch Prefix | When to Use |
|---|---|
| `feat/` | New features — `feat/tutor-profile-page` |
| `fix/` | Bug fixes — `fix/login-crash-on-android` |
| `docs/` | Documentation — `docs/update-setup-guide` |
| `refactor/` | Code cleanup — `refactor/auth-module` |

```bash
# Create and switch to a feature branch
git checkout -b feat/my-feature-name
```

---

### Commit Message Style

Follow this concise, action-based format:

```
feat: add social login with Google
fix: resolve text overflow on tutor card
docs: update backend setup instructions
refactor: simplify auth token validation
```

---

### Pull Request Process

1. **Push your branch:** `git push origin feat/your-feature-name`
2. **Open a PR** on GitHub → "Compare & pull request"
3. **Describe your changes** — what you did and why
4. **Wait for review** — address any feedback
5. **Merge** — once approved, squash-merge into `main`

<br/>

## 📖 Full Documentation

For the complete architectural breakdown, API contracts, database schema, and design decisions, read the **[docs.md](./docs.md)** file.

<br/>

## 📄 License

This project is currently under development and not yet licensed for public distribution. Contact the repository owner for licensing inquiries.

---

<div align="center">

Made with ❤️ by the StudyApp team — **keep learning, keep building!**

[![GitHub](https://img.shields.io/badge/GitHub-hiyokun--d%2Fstudy--app-181717?style=flat-square&logo=github)](https://github.com/hiyokun-d/study-app)

</div>
