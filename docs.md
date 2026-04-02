---
title: Documentation
description: Full developer reference — architecture, API, testing, and how-to guides
permalink: /docs
---

# StudyApp — Developer Documentation

> This document is the single source of truth for how StudyApp is built, how every piece works, and how to extend it. Read this before touching any code.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Environment Setup](#3-environment-setup)
4. [Environment Variables Reference](#4-environment-variables-reference)
5. [Database Schema](#5-database-schema)
6. [Backend — NestJS](#6-backend--nestjs)
   - [How the server starts](#61-how-the-server-starts)
   - [Module system](#62-module-system)
   - [Authentication system](#63-authentication-system)
   - [JWT strategy and guards](#64-jwt-strategy-and-guards)
   - [User module](#65-user-module)
   - [Prisma service](#66-prisma-service)
   - [How to add a new endpoint](#67-how-to-add-a-new-endpoint)
   - [How to add a new module](#68-how-to-add-a-new-module)
7. [API Reference](#7-api-reference)
8. [Frontend — Flutter](#8-frontend--flutter)
   - [How the app starts](#81-how-the-app-starts)
   - [Routing system](#82-routing-system)
   - [Theme system](#83-theme-system)
   - [Core services](#84-core-services)
   - [How AuthState works](#85-how-authstate-works)
   - [How UserApiService works](#86-how-userapiservice-works)
   - [How to add a new API call](#87-how-to-add-a-new-api-call)
   - [How to add a new screen](#88-how-to-add-a-new-screen)
   - [How to add a new route](#89-how-to-add-a-new-route)
   - [Shared widgets](#810-shared-widgets)
9. [Feature Modules](#9-feature-modules)
   - [Auth feature](#91-auth-feature)
   - [Student feature](#92-student-feature)
   - [Teacher feature](#93-teacher-feature)
   - [Chat feature](#94-chat-feature)
   - [Subscription feature](#95-subscription-feature)
10. [Data Models](#10-data-models)
11. [Testing](#11-testing)
    - [How to run tests](#111-how-to-run-tests)
    - [How to write a new service test](#112-how-to-write-a-new-service-test)
    - [How to write a new controller test](#113-how-to-write-a-new-controller-test)
    - [Test configuration explained](#114-test-configuration-explained)
12. [Common How-To Guide](#12-common-how-to-guide)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Project Overview

StudyApp is a peer-to-peer tutoring marketplace. It connects **students** who want to learn with **tutors** who want to teach. The platform is split into two independent codebases that communicate over HTTP:

- **Flutter frontend** — cross-platform mobile/web app (Android, iOS, Web)
- **NestJS backend** — REST API server backed by PostgreSQL

**How it works end-to-end:**
1. A user registers with email/password or Google OAuth
2. They pick a role: `STUDENT` or `TUTOR`
3. They fill in their profile (username, bio, avatar)
4. Students browse tutors, filter by subject/price, view offers, and book sessions
5. Tutors manage their offers, availability, and communicate with students via chat
6. Payments are tracked as transactions tied to bookings
7. After a session both parties can leave reviews

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter App (Client)                   │
│                                                         │
│  ┌──────────────┐  ┌─────────────────────────────────┐  │
│  │  UI Screens  │  │         Core Services           │  │
│  │  (features/) │  │  AuthState  │  UserApiService   │  │
│  └──────────────┘  └─────────────────────────────────┘  │
│           │                      │                      │
│           └──────────────────────┘                      │
│                        │ HTTP / JSON                     │
└────────────────────────│────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│               NestJS Backend (API Server)               │
│                                                         │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │
│  │AuthModule  │  │ UserModule │  │  PrismaModule    │  │
│  │ /auth/*    │  │ /user/*    │  │ (DB connection)  │  │
│  └────────────┘  └────────────┘  └──────────────────┘  │
│                        │                                │
└────────────────────────│────────────────────────────────┘
                         │ SQL (Prisma ORM)
                         ▼
┌─────────────────────────────────────────────────────────┐
│             PostgreSQL (hosted on Supabase)             │
│                                                         │
│  profiles  bookings  messages  reviews  transactions    │
│  tutor_offers  tutor_availabilities  subjects  ...      │
└─────────────────────────────────────────────────────────┘
```

**Key design decisions:**
- Frontend and backend are fully decoupled — they share no code
- Auth is stateless: every protected request carries a JWT Bearer token
- The Flutter app holds auth state in an in-memory singleton (`AuthState`) — there is no local storage persistence yet
- All database access goes through `PrismaService` — never raw SQL
- Passwords are hashed with **argon2** before storing — never stored in plaintext

---

## 3. Environment Setup

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Flutter SDK | `^3.5.0` | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Dart | included with Flutter | — |
| Node.js | `v18+` | [nodejs.org](https://nodejs.org/) |
| npm | included with Node | — |
| Git | any | [git-scm.com](https://git-scm.com/) |
| Supabase account | — | [supabase.com](https://supabase.com/) |

---

### Step 1 — Clone the repo

```bash
git clone https://github.com/hiyokun-d/study-app.git
cd study-app
```

---

### Step 2 — Backend setup

```bash
# Enter the server directory
cd _server

# Install all Node dependencies
npm install

# Copy environment template
cp .env.example .env
```

Open `.env` and fill in these values (see [Section 4](#4-environment-variables-reference) for details):

```env
DATABASE_URL=postgresql://...      # Supabase pooled connection string
DIRECT_URL=postgresql://...        # Supabase direct connection string
JWT_SECRET=your-very-long-secret   # At least 32 random characters
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
PORT=3000
```

```bash
# Generate the Prisma client from the schema
npx prisma generate

# Apply all migrations to the database
npx prisma migrate deploy

# Start the dev server with hot reload
npm run start:dev
```

The API is now running at `http://localhost:3000`.

---

### Step 3 — Frontend setup

```bash
# Go back to project root
cd ..

# Install Flutter dependencies
flutter pub get

# Run on Android emulator (API URL is pre-set for this)
flutter run -d android

# Or run on other platforms
flutter run -d chrome     # Web
flutter run               # First available device
```

> **Note on API URL:** The default `AppConfig.API_URL` is `http://10.0.2.2:3000` which is the Android emulator's way of reaching `localhost` on the host machine. For iOS simulator use `http://localhost:3000`. For a real device or production, update `lib/core/constants/app_config.dart`.

---

### Step 4 — Verify everything works

1. Backend health check: `GET http://localhost:3000/auth` → should return a string message
2. Flutter: launch the app, tap through the splash/onboarding, and try registering a new account

---

## 4. Environment Variables Reference

All backend environment variables live in `_server/.env`. The file is **gitignored** and must never be committed.

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | Yes | Supabase pooled connection string. Used by Prisma for all queries. Format: `postgresql://user:pass@host:port/db?pgbouncer=true` |
| `DIRECT_URL` | Yes | Supabase direct (non-pooled) connection. Used by Prisma for migrations. Format: `postgresql://user:pass@host:port/db` |
| `JWT_SECRET` | Yes | Secret key for signing/verifying JWT tokens. Must match on every deployment. Use a random string of 32+ characters. |
| `GOOGLE_CLIENT_ID` | Yes (for Google login) | OAuth 2.0 Client ID from Google Cloud Console. Required for the `/auth/google` endpoint to verify `idToken`s. |
| `PORT` | No | Port the server listens on. Defaults to `3000`. |

**Where to get these values:**
- `DATABASE_URL` and `DIRECT_URL` — Supabase dashboard → Project Settings → Database → Connection strings
- `JWT_SECRET` — generate with: `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"`
- `GOOGLE_CLIENT_ID` — Google Cloud Console → Credentials → Create OAuth 2.0 Client ID

---

## 5. Database Schema

The database lives in PostgreSQL on Supabase. All schema changes go through Prisma migrations — never edit the DB directly.

Schema file: `_server/prisma/schema.prisma`

---

### `profiles` — User accounts

Every user (student or tutor) has exactly one profile row.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key, auto-generated |
| `email` | `String` | Unique. Required |
| `password` | `String?` | Nullable — Google-only users have no password |
| `full_name` | `String?` | Display name |
| `username` | `String?` | Unique handle |
| `bio` | `String?` | Short description |
| `avatar_url` | `String?` | URL to profile image |
| `role` | `String` | `"STUDENT"` or `"TUTOR"`. Default: `"STUDENT"` |
| `book_price` | `Float` | Tutor's base booking price. Default: `0` |
| `subjects` | `String[]` | Array of subject slugs the tutor teaches |
| `overall_rating` | `Float?` | Calculated average rating |
| `tutor_rating` | `Float?` | Rating as a tutor |
| `student_rating` | `Float?` | Rating as a student |
| `rating_count` | `Int` | Number of reviews received |
| `created_at` | `DateTime` | Auto-set on create |
| `updated_at` | `DateTime` | Must be manually updated on PATCH |

**Relations:** `tutor_offers`, `tutor_availabilities`, `bookings_as_student`, `bookings_as_tutor`, `messages_sent`, `messages_received`, `reviews_given`, `reviews_received`, `transactions`, `notifications`

---

### `bookings` — Tutoring sessions

Represents a booked session between a student and tutor.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `student_id` | `String` | FK → `profiles.id` |
| `tutor_id` | `String` | FK → `profiles.id` |
| `tutor_offer_id` | `String?` | FK → `tutor_offers.id` — which offer was booked |
| `start_at` | `DateTime` | Session start time |
| `end_at` | `DateTime` | Session end time |
| `duration_minutes` | `Int` | Duration in minutes |
| `price` | `Float` | Price paid for this booking |
| `status` | `booking_status` | `pending` → `confirmed` → `completed` or `cancelled` / `failed` |
| `notes` | `String?` | Optional student notes |
| `created_at` | `DateTime` | Auto-set |

**Booking status flow:**
```
pending → confirmed → completed
pending → cancelled
confirmed → cancelled
any → failed  (payment/system error)
```

---

### `tutor_offers` — Tutor service offerings

Each tutor can create multiple offers with different subjects, durations, and prices.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `tutor_id` | `String` | FK → `profiles.id` |
| `title` | `String` | e.g. `"Advanced Calculus — 1 hour"` |
| `summary` | `String?` | Short description of the offer |
| `price_per_hour` | `Float` | Price in local currency |
| `duration_minutes` | `Int` | Fixed duration of this offer |
| `subject_ids` | `String[]` | Array of subject slugs covered |
| `is_active` | `Boolean` | Only `true` offers are shown to students |
| `created_at` | `DateTime` | Auto-set |

---

### `tutor_availabilities` — Tutor schedules

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `tutor_id` | `String` | FK → `profiles.id` |
| `available_from` | `DateTime` | Start of availability window |
| `available_to` | `DateTime` | End of availability window |
| `timezone` | `String` | IANA timezone string (e.g. `"Asia/Jakarta"`) |

---

### `messages` — Chat

Direct messages between two users, optionally tied to a booking.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `from_id` | `String` | FK → `profiles.id` (sender) |
| `to_id` | `String` | FK → `profiles.id` (receiver) |
| `booking_id` | `String?` | FK → `bookings.id` — optional context |
| `content` | `String` | Message text |
| `is_read` | `Boolean` | Whether the receiver has read it |
| `created_at` | `DateTime` | Auto-set |

---

### `reviews` — Ratings

Bi-directional: students can review tutors and tutors can review students.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `reviewer_id` | `String` | FK → `profiles.id` (who wrote it) |
| `reviewee_id` | `String` | FK → `profiles.id` (who was reviewed) |
| `booking_id` | `String?` | FK → `bookings.id` — which session this is for |
| `rating` | `Float` | Numeric score |
| `comment` | `String?` | Optional text |
| `created_at` | `DateTime` | Auto-set |

---

### `transactions` — Payments

Every booking payment, payout, or refund creates a transaction row.

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `profile_id` | `String` | FK → `profiles.id` |
| `booking_id` | `String?` | FK → `bookings.id` |
| `amount` | `Float` | Amount in currency units |
| `currency` | `String` | ISO currency code, e.g. `"IDR"` |
| `kind` | `transaction_kind` | `booking_payment`, `payout`, `refund`, `adjustment` |
| `status` | `String` | `pending`, `completed`, `failed` |
| `created_at` | `DateTime` | Auto-set |

---

### `notifications` — User notifications

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `profile_id` | `String` | FK → `profiles.id` |
| `type` | `String` | e.g. `"booking_confirmed"`, `"new_message"` |
| `payload` | `Json` | Arbitrary data for the notification |
| `seen` | `Boolean` | Whether the user has seen it |
| `created_at` | `DateTime` | Auto-set |

---

### `subjects` — Subject catalog

| Column | Type | Notes |
|---|---|---|
| `id` | `String` (UUID) | Primary key |
| `slug` | `String` | Unique URL-safe identifier, e.g. `"calculus"` |
| `name` | `String` | Display name, e.g. `"Calculus"` |
| `description` | `String?` | Brief description |

---

### How to make a schema change

1. Edit `_server/prisma/schema.prisma`
2. Create a migration:
   ```bash
   cd _server
   npx prisma migrate dev --name describe_your_change
   ```
3. This generates a SQL migration file in `prisma/migrations/` and applies it to your dev DB
4. Regenerate the Prisma client so TypeScript types update:
   ```bash
   npx prisma generate
   ```
5. For production: `npx prisma migrate deploy`

> **Never** edit migration files manually. If you made a mistake, create a new migration to fix it.

---

## 6. Backend — NestJS

### 6.1 How the server starts

Entry point: `_server/src/main.ts`

```
NestFactory.create(AppModule)
  → CORS enabled (all origins, for dev)
  → Listens on PORT (default 3000)
```

`AppModule` imports:
- `ConfigModule.forRoot({ isGlobal: true })` — loads `.env` file, makes `process.env` available everywhere
- `PrismaModule` — provides `PrismaService` globally
- `AuthModule` — registers `/auth/*` routes
- `UserModule` — registers `/user/*` routes

---

### 6.2 Module system

NestJS uses a module system where each domain is encapsulated in its own module. The pattern for every module:

```
src/
└── feature-name/
    ├── feature-name.module.ts      ← imports, providers, exports
    ├── feature-name.controller.ts  ← HTTP routes, request/response handling
    ├── feature-name.service.ts     ← business logic
    └── dto/
        └── some-action.dto.ts      ← request body shape
```

**Controller** = defines HTTP routes, extracts params, calls service
**Service** = business logic, database calls via Prisma
**DTO** = defines the shape and optional validation of incoming request bodies
**Module** = wires controller + service together, declares what it exports

---

### 6.3 Authentication system

File: `_server/src/auth/auth.service.ts`

#### Sign Up

1. Check if email already exists via `prisma.profiles.findUnique`
2. If exists → throw `BadRequestException`
3. Hash password with `argon2.hash(password)`
4. Create the user: `prisma.profiles.create({ data: { email, password: hashedPassword, role: role.toUpperCase(), book_price: 0 } })`
5. Call `generateTokens(id, email, role)` → returns `{ message, access_token, user }`

#### Login

1. Find user by email: `prisma.profiles.findUnique({ where: { email } })`
2. If not found → throw `UnauthorizedException`
3. Verify password: `argon2.verify(storedHash, plainPassword)`
4. If wrong → throw `UnauthorizedException`
5. Call `generateTokens(id, email, role)`

#### Google Login

1. Verify the `idToken` with Google's SDK: `googleClient.verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID })`
2. Extract `email`, `name`, `picture` from the payload
3. If no email in payload → throw `UnauthorizedException`
4. Look up user by email
5. If user doesn't exist → create with `full_name`, `avatar_url`, `book_price: 0`
6. If user exists but is missing `full_name` or `avatar_url` → update those fields
7. Call `generateTokens(id, email, role)`

#### Token generation (`generateTokens`)

```typescript
private generateTokens(userId: string, email: string, role: string) {
  const payload = { sub: userId, email, role };
  return {
    message: 'Authentication successful',
    access_token: this.jwtService.sign(payload),  // 7 day expiry
    user: { id: userId, email, role },
  };
}
```

JWT payload contains: `sub` (user ID), `email`, `role`

---

### 6.4 JWT strategy and guards

File: `_server/src/auth/jwt.strategy.ts`

The JWT strategy runs **automatically** on every request that uses `@UseGuards(AuthGuard('jwt'))`.

**Flow:**
1. Extracts the Bearer token from `Authorization` header
2. Verifies the signature with `JWT_SECRET`
3. Calls `validate(payload)`:
   - Looks up the user in the DB: `prisma.profiles.findUnique({ where: { id: payload.sub } })`
   - If not found → throws `UnauthorizedException`
   - Returns `{ userId: payload.sub, email: payload.email, role: payload.role }`
4. The returned object is attached to `req.user`

**How to protect a route:**

```typescript
import { UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Get('something-protected')
async myProtectedRoute(@Request() req: any) {
  const userId = req.user.userId; // from jwt.strategy validate()
  // ...
}
```

**How to get the user ID from the token** (as done in `user.controller.ts`):

```typescript
const userId = req.user.userId || req.user.sub || req.user.id;
if (!userId) throw new UnauthorizedException('...');
```

The triple fallback covers different JWT payload structures that might appear in different environments.

---

### 6.5 User module

File: `_server/src/user/user.service.ts`

#### `getAllTutorProfile()`
Fetches all users with `role: 'TUTOR'`. Returns only safe public fields (no email/password).

#### `getAllStudentProfile()`
Fetches all users with `role: 'STUDENT'`. Returns public fields.

#### `getTutorFilteredBy(search?, subject?, maxPrice?)`
Dynamic query builder using Prisma's spread-based `where` composition:
- `search` → adds `OR: [{ full_name: contains }, { username: contains }]` (case-insensitive)
- `subject` → adds `subjects: { has: subject }`
- `maxPrice` → adds `book_price: { lte: maxPrice }`

Results are ordered by `created_at: 'desc'`.

#### `getTutorDetailProfile(tutorID)`
Fetches a single tutor with their active `tutor_offers`. Throws `NotFoundException` if not found.

#### `updateProfile(userId, data: UpdateProfileDTO)`
1. Validates `userId` is not empty (throws `BadRequestException`)
2. Checks user exists (throws `NotFoundException`)
3. Updates with only the provided fields
4. Always sets `updated_at: new Date()`
5. Returns `{ message, user }` with selected safe fields

---

### 6.6 Prisma service

File: `_server/src/prisma.service.ts`

```typescript
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
    super({ adapter });
  }

  async onModuleInit() {
    await this.$connect();
  }
}
```

`PrismaService` extends `PrismaClient` directly, so you get `this.prisma.profiles.findMany(...)` type-safe access everywhere it's injected.

It's provided globally via `PrismaModule` (which has `isGlobal: true`) so you can inject it into any service without re-importing the module:

```typescript
constructor(private prisma: PrismaService) {}
```

---

### 6.7 How to add a new endpoint

**Example: add `GET /user/profile` to get the authenticated user's own profile.**

**Step 1 — Add the method to `user.service.ts`:**

```typescript
async getMyProfile(userId: string) {
  const user = await this.prisma.profiles.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      full_name: true,
      username: true,
      bio: true,
      avatar_url: true,
      role: true,
    },
  });

  if (!user) throw new NotFoundException('User not found');
  return user;
}
```

**Step 2 — Add the route to `user.controller.ts`:**

```typescript
@UseGuards(AuthGuard('jwt'))
@Get('profile')
async getMyProfile(@Request() req: any) {
  const userId = req.user.userId || req.user.sub || req.user.id;
  if (!userId) throw new UnauthorizedException('Identification missing');
  return this.userService.getMyProfile(userId);
}
```

**Step 3 — Write a test in `user.service.spec.ts`:**

```typescript
describe('getMyProfile', () => {
  it('should return profile for given userId', async () => {
    const mockUser = { id: 'u1', email: 'me@example.com', role: 'STUDENT' };
    mockPrisma.profiles.findUnique.mockResolvedValue(mockUser);

    const result = await service.getMyProfile('u1');
    expect(result).toEqual(mockUser);
  });

  it('should throw NotFoundException when user not found', async () => {
    mockPrisma.profiles.findUnique.mockResolvedValue(null);
    await expect(service.getMyProfile('ghost')).rejects.toThrow(NotFoundException);
  });
});
```

**Step 4 — Run tests:**

```bash
cd _server && npm test
```

---

### 6.8 How to add a new module

**Example: adding a `BookingModule`.**

**Step 1 — Create the files:**

```bash
mkdir -p _server/src/booking/dto
touch _server/src/booking/booking.module.ts
touch _server/src/booking/booking.controller.ts
touch _server/src/booking/booking.service.ts
touch _server/src/booking/dto/create-booking.dto.ts
```

**Step 2 — `create-booking.dto.ts`:**

```typescript
export class CreateBookingDTO {
  tutor_id: string;
  tutor_offer_id?: string;
  start_at: string;   // ISO date string
  notes?: string;
}
```

**Step 3 — `booking.service.ts`:**

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { CreateBookingDTO } from './dto/create-booking.dto';

@Injectable()
export class BookingService {
  constructor(private prisma: PrismaService) {}

  async createBooking(studentId: string, dto: CreateBookingDTO) {
    // implementation
  }
}
```

**Step 4 — `booking.module.ts`:**

```typescript
import { Module } from '@nestjs/common';
import { BookingController } from './booking.controller';
import { BookingService } from './booking.service';

@Module({
  controllers: [BookingController],
  providers: [BookingService],
})
export class BookingModule {}
```

**Step 5 — Register in `app.module.ts`:**

```typescript
import { BookingModule } from './booking/booking.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UserModule,
    BookingModule,   // ← add here
  ],
  // ...
})
export class AppModule {}
```

---

## 7. API Reference

**Base URL:** `http://localhost:3000` (dev) — update `AppConfig.API_URL` for production.

**Authentication:** Protected routes require the header:
```
Authorization: Bearer <access_token>
```

---

### `GET /auth`
**Health check.** No auth required.

```
Response 200: "You're at the right path, continue!"
```

---

### `POST /auth/signup`
**Register a new account.** No auth required.

**Request body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword",
  "role": "STUDENT"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string | Yes | Must be unique |
| `password` | string | Yes | Hashed with argon2 before storing |
| `role` | string | No | `"STUDENT"` or `"TUTOR"`. Defaults to `"STUDENT"` |

**Response `201`:**
```json
{
  "message": "Authentication successful",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "role": "STUDENT"
  }
}
```

**Error responses:**
| Status | When |
|---|---|
| `400 Bad Request` | Email already registered |

---

### `POST /auth/login`
**Log in with email and password.** No auth required.

**Request body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response `200`:**
```json
{
  "message": "Authentication successful",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "role": "STUDENT"
  }
}
```

**Error responses:**
| Status | When |
|---|---|
| `401 Unauthorized` | Email not found |
| `401 Unauthorized` | Password is incorrect |

---

### `POST /auth/google`
**Sign in or register via Google OAuth.** No auth required.

The client app must first get a Google `idToken` using the Google Sign-In SDK, then send it here.

**Request body:**
```json
{
  "idToken": "google-id-token-from-client",
  "role": "STUDENT"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `idToken` | string | Yes | From Google Sign-In SDK |
| `role` | string | Yes | `"STUDENT"` or `"TUTOR"` |

**Response `200`:**
```json
{
  "message": "Google Login successful!",
  "access_token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "email": "john@gmail.com",
    "role": "STUDENT",
    "full_name": "John Doe",
    "avatar_url": "https://lh3.googleusercontent.com/..."
  }
}
```

**Error responses:**
| Status | When |
|---|---|
| `401 Unauthorized` | Invalid or expired Google token |
| `401 Unauthorized` | Google token has no email |

---

### `GET /user`
**Dummy endpoint.** Returns a timestamp. No auth required.

```json
{
  "message": "This is a dummy response from the UserController.",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### `GET /user/tutors/all`
**Get all tutors.** No auth required.

Returns an array of all tutor profiles with public fields:

```json
[
  {
    "id": "uuid",
    "full_name": "Alice Smith",
    "username": "alice",
    "avatar_url": "https://...",
    "bio": "Math tutor with 5 years experience",
    "book_price": 150000,
    "subjects": ["calculus", "algebra"],
    "overall_rating": 4.8,
    "rating_count": 24,
    "tutor_rating": 4.9
  }
]
```

---

### `GET /user/student`
**Get all students.** No auth required.

```json
[
  {
    "id": "uuid",
    "full_name": "Bob Jones",
    "username": "bob",
    "avatar_url": "https://...",
    "bio": "First year CS student",
    "student_rating": 4.5
  }
]
```

---

### `GET /user/tutors`
**Search and filter tutors.** No auth required.

**Query parameters:**

| Param | Type | Description | Example |
|---|---|---|---|
| `search` | string | Case-insensitive search on `full_name` and `username` | `?search=alice` |
| `subject` | string | Filter by exact subject slug | `?subject=calculus` |
| `maxPrice` | number | Maximum `book_price` | `?maxPrice=150000` |

All params are optional and can be combined:
```
GET /user/tutors?search=math&subject=algebra&maxPrice=100000
```

Returns the same shape as `GET /user/tutors/all`.

---

### `GET /user/tutor/:id`
**Get a single tutor's full profile with their active offers.** No auth required.

```
GET /user/tutor/550e8400-e29b-41d4-a716-446655440000
```

**Response `200`:**
```json
{
  "id": "uuid",
  "full_name": "Alice Smith",
  "username": "alice",
  "avatar_url": "https://...",
  "bio": "Math tutor",
  "book_price": 150000,
  "subjects": ["calculus"],
  "overall_rating": 4.8,
  "tutor_rating": 4.9,
  "tutor_offers": [
    {
      "id": "offer-uuid",
      "title": "Calculus Basics — 1 Hour",
      "summary": "Intro to derivatives and integrals",
      "price_per_hour": 150000,
      "duration_minutes": 60
    }
  ]
}
```

**Error responses:**
| Status | When |
|---|---|
| `404 Not Found` | Tutor ID doesn't exist or user is not a TUTOR |

---

### `PATCH /user/update/profile`
**Update the authenticated user's own profile.** 🔒 Requires JWT.

All fields are optional — only send the ones you want to change.

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request body:**
```json
{
  "full_name": "John Doe",
  "username": "john_doe",
  "bio": "Passionate math tutor with 5 years experience.",
  "avatar_url": "https://example.com/avatar.png",
  "role": "TUTOR"
}
```

| Field | Type | Notes |
|---|---|---|
| `full_name` | string? | Display name |
| `username` | string? | Unique handle |
| `bio` | string? | Short description |
| `avatar_url` | string? | URL to profile picture |
| `role` | string? | `"STUDENT"` or `"TUTOR"` — will be uppercased automatically |

**Response `200`:**
```json
{
  "message": "Profile updated successfully!",
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

**Error responses:**
| Status | When |
|---|---|
| `401 Unauthorized` | No/invalid JWT token |
| `401 Unauthorized` | User ID cannot be extracted from token |
| `400 Bad Request` | userId is empty (internal check) |
| `404 Not Found` | User no longer exists in DB |

---

## 8. Frontend — Flutter

### 8.1 How the app starts

Entry point: `lib/main.dart`

```dart
void main() {
  runApp(StudyApp());
}
```

`StudyApp` is a `StatelessWidget` that returns `MaterialApp` (or `MaterialApp.router`) with:
- The theme from `AppTheme`
- The route map from `AppRoutes`
- Initial route pointing to the splash screen

---

### 8.2 Routing system

File: `lib/routes/app_routes.dart`

All routes are defined as named string constants and mapped to screen builders. The app uses `Navigator.of(context).pushNamed('/route-name')` for navigation.

**Available routes:**

| Route | Screen | Notes |
|---|---|---|
| `/` | Splash screen | App entry point |
| `/onboarding` | Onboarding screen | First-time users |
| `/login` | Login screen | |
| `/register` | Register screen | |
| `/role-selection` | Role selection | After registration |
| `/update-profile` | Update profile | After role selection |
| `/student` | Student dashboard | Main student view |
| `/teacher` | Teacher dashboard | Main teacher view |
| `/chat` | Chat detail | |
| `/subscription` | Subscription plans | |
| `/payment` | Payment screen | |
| `/payment-success` | Payment success | |

**Navigate to a route:**
```dart
Navigator.of(context).pushNamed('/login');
```

**Navigate and replace current (can't go back):**
```dart
Navigator.of(context).pushReplacementNamed('/student');
```

**Navigate with arguments:**
```dart
Navigator.of(context).pushNamed('/chat', arguments: { 'userId': '123' });

// Receive in the target screen:
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
```

---

### 8.3 Theme system

**Files:**
- `lib/core/themes/app_theme.dart` — `ThemeData` for light and dark mode
- `lib/core/themes/app_colors.dart` — all color constants
- `lib/core/themes/app_typography.dart` — text style helpers
- `lib/core/themes/app_sizes.dart` — spacing, radii, size constants

**Primary color:** `0xFF1479FF` (blue)

**Using colors:**
```dart
import 'package:myapp/core/themes/app_colors.dart';

Container(color: AppColors.primary)
Container(color: AppColors.error)
```

**Using typography:**
```dart
import 'package:myapp/core/themes/app_typography.dart';

Text('Hello', style: AppTypography.headline)
Text('Subtitle', style: AppTypography.subtitle)
Text('Click here', style: AppTypography.link)
```

**Using sizes:**
```dart
import 'package:myapp/core/themes/app_sizes.dart';

SizedBox(height: AppSizes.spacingMd)
BorderRadius.circular(AppSizes.radiusMd)
```

---

### 8.4 Core services

Both services in `lib/core/services/` use the **singleton pattern** — one instance shared across the entire app, no `BuildContext` needed.

```
lib/core/services/
├── auth_state.dart        ← stores the JWT token and user info
└── user_api_service.dart  ← all user API calls
```

---

### 8.5 How AuthState works

File: `lib/core/services/auth_state.dart`

`AuthState` is an in-memory singleton. It survives screen navigation but is wiped if the app process is killed (there is no persistent storage yet).

**What it stores:**

| Field | Type | Set by |
|---|---|---|
| `accessToken` | `String?` | `setFromResponse()` after login/signup |
| `userId` | `String?` | `setFromResponse()` |
| `email` | `String?` | `setFromResponse()` |
| `role` | `String?` | `setFromResponse()` or manually after profile update |

**How to use it:**

```dart
import 'package:myapp/core/services/auth_state.dart';

// After a successful login/signup API call:
final responseBody = jsonDecode(response.body);
AuthState.instance.setFromResponse(responseBody);

// Read values anywhere in the app:
final token = AuthState.instance.accessToken;
final role  = AuthState.instance.role;   // 'STUDENT' or 'TUTOR'
final isLoggedIn = AuthState.instance.isLoggedIn;  // bool

// Get pre-built auth headers for HTTP requests:
final headers = AuthState.instance.authHeaders;
// → { 'Content-Type': 'application/json', 'Authorization': 'Bearer eyJ...' }

// On logout:
AuthState.instance.clear();
Navigator.of(context).pushReplacementNamed('/login');
```

**Updating role after profile change:**
```dart
// After updateProfile succeeds, sync the role:
AuthState.instance.role = result.user?['role']?.toString();
```

---

### 8.6 How UserApiService works

File: `lib/core/services/user_api_service.dart`

A singleton service that handles all user-related HTTP calls. It:
- Automatically attaches the JWT from `AuthState`
- Never throws — all errors are returned as a result object
- Only includes fields you pass (nulls are omitted from the request body)

**Current methods:**

#### `updateProfile(...)`

```dart
final result = await UserApiService.instance.updateProfile(
  username: 'john_doe',       // optional
  fullName: 'John Doe',       // optional
  bio: 'I love math',         // optional
  role: 'STUDENT',            // optional — 'STUDENT' or 'TUTOR'
  avatarUrl: 'https://...',   // optional
);

if (result.success) {
  final user = result.user;              // Map<String, dynamic>
  print(user?['username']);              // 'john_doe'
  print(user?['role']);                  // 'STUDENT'
} else {
  print(result.errorMessage);           // user-friendly error string
}
```

**Return type:** `UpdateProfileResult`

| Field | Type | Notes |
|---|---|---|
| `success` | `bool` | Whether the request succeeded |
| `user` | `Map<String, dynamic>?` | Updated user object (only on success) |
| `errorMessage` | `String?` | Error description (only on failure) |

---

### 8.7 How to add a new API call

**Example: add `getTutors()` to browse tutors.**

**Step 1 — Define a result class** at the bottom of `user_api_service.dart`:

```dart
class GetTutorsResult {
  final bool success;
  final List<Map<String, dynamic>>? tutors;
  final String? errorMessage;

  const GetTutorsResult._({required this.success, this.tutors, this.errorMessage});

  factory GetTutorsResult.success(List<Map<String, dynamic>> tutors) =>
      GetTutorsResult._(success: true, tutors: tutors);

  factory GetTutorsResult.error(String message) =>
      GetTutorsResult._(success: false, errorMessage: message);
}
```

**Step 2 — Add the method** to `UserApiService`:

```dart
Future<GetTutorsResult> getTutors({
  String? search,
  String? subject,
  double? maxPrice,
}) async {
  final queryParams = <String, String>{};
  if (search != null) queryParams['search'] = search;
  if (subject != null) queryParams['subject'] = subject;
  if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

  try {
    final uri = Uri.parse('${AppConfig.API_URL}/user/tutors')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final list = (data as List).cast<Map<String, dynamic>>();
      return GetTutorsResult.success(list);
    }
    return GetTutorsResult.error('Failed to load tutors');
  } catch (e) {
    return GetTutorsResult.error('Network error: $e');
  }
}
```

**Step 3 — Use it in a widget:**

```dart
final result = await UserApiService.instance.getTutors(search: 'math');

if (result.success) {
  setState(() {
    _tutors = result.tutors!;
  });
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.errorMessage!)),
  );
}
```

**Rules to follow:**
- Protected endpoints: always check `AuthState.instance.isLoggedIn` first, return an error result if not logged in
- Pass `headers: AuthState.instance.authHeaders` for protected endpoints
- Use `http.get` for GET, `http.post` for POST, `http.patch` for PATCH
- Always wrap in `try/catch` and return `.error(...)` in the catch block
- Never throw from a service method

---

### 8.8 How to add a new screen

**Example: adding a `TutorDetailScreen`.**

**Step 1 — Create the file:**

```
lib/features/student/screens/tutor_detail_screen.dart
```

**Step 2 — Write the screen:**

```dart
import 'package:flutter/material.dart';
import '../../../core/services/user_api_service.dart';

class TutorDetailScreen extends StatefulWidget {
  final String tutorId;
  const TutorDetailScreen({super.key, required this.tutorId});

  @override
  State<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends State<TutorDetailScreen> {
  Map<String, dynamic>? _tutor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutor();
  }

  Future<void> _loadTutor() async {
    // call your API service here
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(_tutor?['full_name'] ?? 'Tutor')),
      body: const Placeholder(),
    );
  }
}
```

**Step 3 — Register the route** (see next section).

---

### 8.9 How to add a new route

**Step 1 — Add the route constant and builder** in `lib/routes/app_routes.dart`:

```dart
// Add a constant for the path
static const String tutorDetail = '/tutor-detail';

// Add to the routes map:
AppRoutes.tutorDetail: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  return TutorDetailScreen(tutorId: args['tutorId'] as String);
},
```

**Step 2 — Navigate to it:**

```dart
Navigator.of(context).pushNamed(
  AppRoutes.tutorDetail,
  arguments: { 'tutorId': 'some-uuid' },
);
```

---

### 8.10 Shared widgets

Located in `lib/core/widgets/`. Use these instead of building from scratch.

#### `PrimaryButton`

```dart
PrimaryButton(
  label: 'Continue',
  onPressed: () { /* ... */ },
  isLoading: _isLoading,   // shows spinner, disables button
  size: ButtonSize.large,  // small / medium / large
)
```

#### `TextInput`

```dart
TextInput(
  controller: _emailController,
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
  validator: (val) => val!.isEmpty ? 'Required' : null,
)
```

#### `PasswordTextField`

```dart
PasswordTextField(
  controller: _passwordController,
  label: 'Password',
)
```
Has a built-in visibility toggle.

#### `AvatarWidget`

```dart
AvatarWidget(
  imageUrl: user.avatarUrl,
  name: user.fullName,    // used for initials fallback
  size: AvatarSize.lg,    // sm / md / lg / xl
)
```

#### `SearchInput`

```dart
SearchInput(
  onChanged: (query) => _search(query),
  onFilterTap: () => _openFilters(),
)
```

---

## 9. Feature Modules

### 9.1 Auth feature

`lib/features/auth/screens/`

| Screen | Route | What it does |
|---|---|---|
| `splash_screen.dart` | `/` | Animated logo + fade in. Auto-navigates after 2500ms. Decide where to send the user (onboarding vs dashboard) based on `AuthState.instance.isLoggedIn` |
| `onboarding_screen.dart` | `/onboarding` | 4-page swipeable intro. Last page has "Get Started" button |
| `login_screen.dart` | `/login` | Email + password form. Calls `POST /auth/login`. Also has Google Sign-In button |
| `register_screen.dart` | `/register` | Email + password + confirm-password. Calls `POST /auth/signup`. Redirects to `/update-profile` on success |
| `update_profile_screen.dart` | `/update-profile` | Full name, username, bio, role dropdown. Calls `UserApiService.instance.updateProfile()`. Redirects to `/teacher` or `/student` based on role |

**Login flow:**
```
/login
  → POST /auth/login
  → AuthState.instance.setFromResponse(data)
  → navigate to /student or /teacher based on AuthState.instance.role
```

**Register flow:**
```
/register
  → POST /auth/signup
  → AuthState.instance.setFromResponse(data)
  → navigate to /update-profile
      → UserApiService.instance.updateProfile(...)
      → AuthState.instance.role = result.user['role']
      → navigate to /student or /teacher
```

---

### 9.2 Student feature

`lib/features/student/screens/`

| Screen | Purpose |
|---|---|
| `student_dashboard.dart` | 5-tab bottom navigation: Home, Explore, Learning, Messages, Profile |
| `course_detail_screen.dart` | Tabbed view: Overview, Curriculum, Reviews. Shows tutor info and "Book" button |
| `live_class_screen.dart` | Pre-join screen for live sessions |

---

### 9.3 Teacher feature

`lib/features/teacher/screens/`

| Screen | Purpose |
|---|---|
| `teacher_dashboard.dart` | 5-tab bottom navigation: Home, Courses, Students, Earnings, Profile |

---

### 9.4 Chat feature

`lib/features/chat/screens/`

| Screen | Purpose |
|---|---|
| `chat_detail_screen.dart` | Full chat view with message list, typing indicator, and message input |

---

### 9.5 Subscription feature

`lib/features/subscription/screens/`

| Screen | Purpose |
|---|---|
| `subscription_plans_screen.dart` | Shows 3 plans: Free, Premium, Pro. Toggle for monthly/yearly pricing |
| `payment_screen.dart` | Payment method selection (Card, PayPal, Bank Transfer) + order summary |
| `payment_success_screen.dart` | Animated success screen with transaction details |

---

## 10. Data Models

Flutter-side models in `lib/models/`. These are used for UI data only — they don't hit the API directly.

### `UserModel`

```dart
UserModel {
  id: String
  name: String
  email: String
  avatarUrl: String?
  role: UserRole  // UserRole.student | UserRole.teacher
}
```

### `CourseModel`

```dart
CourseModel {
  id: String
  title: String
  description: String
  thumbnailUrl: String
  teacher: TeacherModel
  price: double
  category: String
  level: CourseLevel       // beginner | intermediate | advanced
  status: CourseStatus     // draft | published | archived
  sections: List<CourseSection>
  rating: double
  studentsCount: int
}
```

### `TeacherModel` (extends UserModel)

```dart
TeacherModel {
  // inherits UserModel fields
  bio: String
  expertise: List<String>
  education: String
  rating: double
  studentsCount: int
  coursesCount: int
}
```

### `LiveClassModel`

```dart
LiveClassModel {
  id: String
  title: String
  teacher: TeacherModel
  scheduledAt: DateTime
  durationMinutes: int
  viewerCount: int
  maxViewers: int
  subject: String
  meetingUrl: String?
  isLive: bool
}
```

---

## 11. Testing

### 11.1 How to run tests

```bash
# Run all unit tests
cd _server && npm test

# Watch mode — re-runs on every file save
cd _server && npm run test:watch

# With coverage report
cd _server && npm run test:cov

# Flutter tests
flutter test
```

**Current test results:** 62 tests across 5 suites, all passing.

---

### 11.2 How to write a new service test

Every service test follows this pattern: mock `PrismaService`, inject it, test the business logic.

```typescript
// _server/src/my-feature/my-feature.service.spec.ts

import { Test, TestingModule } from '@nestjs/testing';
import { MyFeatureService } from './my-feature.service';
import { PrismaService } from 'src/prisma.service';
import { NotFoundException } from '@nestjs/common';

// 1. Mock PrismaService — only the methods your service calls
const mockPrisma = {
  myTable: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
};

describe('MyFeatureService', () => {
  let service: MyFeatureService;

  beforeEach(async () => {
    jest.clearAllMocks(); // reset call counts between tests

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MyFeatureService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<MyFeatureService>(MyFeatureService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('doSomething', () => {
    it('should return data on success', async () => {
      const mockData = { id: '1', name: 'Test' };
      mockPrisma.myTable.findUnique.mockResolvedValue(mockData);

      const result = await service.doSomething('1');

      expect(mockPrisma.myTable.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id: '1' } })
      );
      expect(result).toEqual(mockData);
    });

    it('should throw NotFoundException when record is missing', async () => {
      mockPrisma.myTable.findUnique.mockResolvedValue(null);

      await expect(service.doSomething('ghost')).rejects.toThrow(NotFoundException);
    });
  });
});
```

**Rules for service tests:**
- Always call `jest.clearAllMocks()` in `beforeEach`
- Test both the happy path AND every error path
- Use `expect.objectContaining(...)` to check partial call arguments
- Use `.toHaveBeenCalledWith(...)` to verify Prisma was called correctly
- Use `.not.toHaveBeenCalled()` to verify something was NOT called (e.g., no `create` on duplicate)

---

### 11.3 How to write a new controller test

Controller tests mock the **service** (not Prisma directly), and test that routes call the right service methods with the right arguments.

```typescript
// _server/src/my-feature/my-feature.controller.spec.ts

import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { MyFeatureController } from './my-feature.controller';
import { MyFeatureService } from './my-feature.service';
import { AuthGuard } from '@nestjs/passport';

// 1. Mock the service
const mockService = {
  doSomething: jest.fn(),
  doSomethingElse: jest.fn(),
};

// 2. Override the JWT guard so tests don't need real tokens
const mockAuthGuard = { canActivate: jest.fn().mockReturnValue(true) };

describe('MyFeatureController', () => {
  let controller: MyFeatureController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [MyFeatureController],
      providers: [{ provide: MyFeatureService, useValue: mockService }],
    })
      .overrideGuard(AuthGuard('jwt'))
      .useValue(mockAuthGuard)
      .compile();

    controller = module.get<MyFeatureController>(MyFeatureController);
  });

  describe('GET /my-feature/:id', () => {
    it('should call service and return result', async () => {
      const mockResult = { id: '1', data: 'value' };
      mockService.doSomething.mockResolvedValue(mockResult);

      const result = await controller.getSomething('1');

      expect(mockService.doSomething).toHaveBeenCalledWith('1');
      expect(result).toEqual(mockResult);
    });

    it('should propagate NotFoundException from service', async () => {
      mockService.doSomething.mockRejectedValue(new NotFoundException());
      await expect(controller.getSomething('ghost')).rejects.toThrow(NotFoundException);
    });
  });
});
```

---

### 11.4 Test configuration explained

The Jest config lives in the `"jest"` key of `_server/package.json`:

```json
{
  "rootDir": "src",
  "testRegex": ".*\\.spec\\.ts$",
  "transform": { "^.+\\.(t|j)s$": "ts-jest" },
  "moduleNameMapper": {
    "^src/(.*)$": "<rootDir>/$1",
    "^(\\.{1,2}/.*)\\.js$": "$1"
  },
  "testEnvironment": "node"
}
```

| Setting | Why it's there |
|---|---|
| `rootDir: "src"` | All test paths are relative to `src/` |
| `testRegex: .*\\.spec\\.ts$` | Only files ending in `.spec.ts` are treated as tests |
| `ts-jest` transform | Compiles TypeScript to JS before running tests |
| `^src/(.*)$ → <rootDir>/$1` | Resolves absolute `import { X } from 'src/...'` imports |
| `(\\.{1,2}/.*)\\.js$ → $1` | Strips `.js` extensions from relative imports — needed because the generated Prisma client uses ESM-style `import ... from './file.js'` which Jest (CommonJS) can't resolve without this |

---

## 12. Common How-To Guide

### How do I check if a user is logged in?

```dart
if (AuthState.instance.isLoggedIn) {
  // user has a token
} else {
  Navigator.of(context).pushReplacementNamed('/login');
}
```

---

### How do I make an authenticated HTTP request manually?

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/core/constants/app_config.dart';
import 'package:myapp/core/services/auth_state.dart';

final response = await http.get(
  Uri.parse('${AppConfig.API_URL}/some/endpoint'),
  headers: AuthState.instance.authHeaders,
);

final data = jsonDecode(response.body);
```

---

### How do I redirect after login based on role?

```dart
final role = AuthState.instance.role;
if (role == 'TUTOR') {
  Navigator.of(context).pushReplacementNamed('/teacher');
} else {
  Navigator.of(context).pushReplacementNamed('/student');
}
```

---

### How do I log a user out?

```dart
AuthState.instance.clear();
Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
```

The second argument `(route) => false` removes all previous routes from the stack so the user can't press Back to return to the dashboard.

---

### How do I handle loading states in a screen?

```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _doAction() async {
    setState(() => _isLoading = true);

    final result = await UserApiService.instance.updateProfile(username: 'test');

    if (!mounted) return; // always check after await
    setState(() => _isLoading = false);

    if (result.success) {
      // handle success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }
}
```

The `if (!mounted) return` check after every `await` is **critical** — the widget might have been removed from the tree while the request was in flight.

---

### How do I add a form with validation?

```dart
final _formKey = GlobalKey<FormState>();
final _controller = TextEditingController();

// In build():
Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(
      controller: _controller,
      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
    ),
    ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // form is valid — proceed
        }
      },
      child: const Text('Submit'),
    ),
  ]),
)
```

---

### How do I protect a NestJS route with JWT?

```typescript
import { UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Get('protected')
async myRoute(@Request() req: any) {
  // req.user is populated by JwtStrategy.validate()
  const userId = req.user.userId || req.user.sub || req.user.id;
  // ...
}
```

---

### How do I query the database in a service?

```typescript
// Inject PrismaService in the constructor:
constructor(private prisma: PrismaService) {}

// Then use it:
const user = await this.prisma.profiles.findUnique({ where: { id: userId } });
const tutors = await this.prisma.profiles.findMany({ where: { role: 'TUTOR' } });
const updated = await this.prisma.profiles.update({
  where: { id: userId },
  data: { bio: 'New bio' },
});
```

---

### How do I run a database migration?

```bash
cd _server

# Dev: creates migration file + applies it
npx prisma migrate dev --name add_column_to_profiles

# Production: applies pending migrations
npx prisma migrate deploy

# After any schema change, regenerate the TS types
npx prisma generate
```

---

### How do I inspect the database?

```bash
cd _server
npx prisma studio
```

Opens a browser UI at `http://localhost:5555` where you can browse and edit all tables.

---

### How do I change the API base URL for production?

Edit `lib/core/constants/app_config.dart`:

```dart
class AppConfig {
  AppConfig._();
  static const String API_URL = "https://your-production-api.com";
}
```

For different environments (dev/staging/prod), consider using `--dart-define` flags or a `.env` loader package.

---

## 13. Troubleshooting

### `Cannot find module 'src/prisma.service'`

Jest can't resolve absolute `src/` imports. Make sure `package.json` has this in the `jest` config:

```json
"moduleNameMapper": {
  "^src/(.*)$": "<rootDir>/$1"
}
```

---

### `Cannot find module './internal/class.js'`

The generated Prisma client uses ESM `.js` extensions. Add this to the `jest` `moduleNameMapper`:

```json
"^(\\.{1,2}/.*)\\.js$": "$1"
```

---

### API returns `401 Unauthorized` on a protected route

1. Check that you're sending the `Authorization: Bearer <token>` header
2. Check that `AuthState.instance.accessToken` is not `null`
3. Check that the token hasn't expired (JWT expires in 7 days)
4. Check that `JWT_SECRET` in `.env` matches what was used to sign the token

---

### Flutter app can't reach the API

- **Android emulator:** API URL must be `http://10.0.2.2:3000` (not `localhost`)
- **iOS simulator:** API URL can be `http://localhost:3000`
- **Physical device:** API URL must be your machine's LAN IP, e.g. `http://192.168.1.x:3000`
- **Production:** Use your server's domain with HTTPS

Update `lib/core/constants/app_config.dart` accordingly.

---

### Prisma migration fails

```bash
# Reset dev database (DESTROYS ALL DATA — dev only)
npx prisma migrate reset

# Then reapply
npx prisma migrate dev
```

---

### `PrismaClientInitializationError` on server start

- Check that `DATABASE_URL` in `.env` is correct
- Check that your Supabase project is active and not paused (free tier pauses after inactivity)
- Try `npx prisma db push` to verify the connection

---

### `argon2` native module error on install

argon2 is a native Node module. If `npm install` fails:

```bash
npm install --ignore-scripts
npm rebuild argon2
```

---

### Test fails with `TypeError: A dynamic import callback was invoked without --experimental-vm-modules`

Don't use `await import(...)` inside test files. Use static imports at the top of the file:

```typescript
// ❌ wrong
const { NotFoundException } = await import('@nestjs/common');

// ✓ correct
import { NotFoundException } from '@nestjs/common';
```
