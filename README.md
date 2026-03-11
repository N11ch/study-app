# 🎓 StudyApp: Peer-to-Peer Tutoring Marketplace

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/nestjs-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)](https://nestjs.com/)
[![Prisma](https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white)](https://www.prisma.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

**StudyApp** is a modern, decoupled educational platform designed to connect students directly with expert tutors. By moving away from rigid curriculums, StudyApp empowers students to choose what they learn, who they learn from, and when they learn.

---

## 📖 Deep Documentation

For the full architectural breakdown, concept details, and feature specifications, please read the **[Documentation (docs.md)](./docs.md)**.

---

## 🛠 Tech Stack

### Frontend (Mobile & Web)

- **Framework:** Flutter (Dart)
- **Architecture:** Feature-first modular design.
- **UI:** Custom design system with Material 3 support.

### Backend (API & Business Logic)

- **Framework:** NestJS (Node.js/TypeScript).
- **ORM:** Prisma (Type-safe database access).
- **Database:** PostgreSQL (Hosted on Supabase).
- **Authentication:** JWT-based secure authentication.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.5.0)
- [Node.js](https://nodejs.org/) (v18+ recommended) & npm
- [Git](https://git-scm.com/)

---

### 1️⃣ Frontend Setup (Flutter)

```bash
# Install dependencies
flutter pub get

# Run the application
flutter run
```

### 2️⃣ Backend Setup (NestJS)

```bash
# Navigate to server directory
cd _server

# Install dependencies
npm install

# Configure environment variables
# 1. Copy the example file
cp .env.example .env
# 2. Edit .env and add your DATABASE_URL and DIRECT_URL (Supabase connection strings)

# Generate Prisma client
npx prisma generate

# Start the development server
npm run start:dev
```

---

## 🤝 GitHub Collaboration Guide

To maintain high code quality and avoid conflicts, please follow this professional workflow:

### 1. The Golden Rule

**Never push directly to `main`.** All changes must go through a Feature Branch and a Pull Request (PR).

### 2. Branching Strategy

Use descriptive names for your branches:

- `feat/name-of-feature` (New features)
- `fix/description-of-bug` (Bug fixes)
- `docs/what-was-updated` (Documentation changes)
- `refactor/what-was-cleaned` (Code improvements without new features)

```bash
# Create and switch to a new branch
git checkout -b feat/login-screen
```

### 3. Professional Commit Messages

We follow a concise "action-based" commit style:

- `feat: added social login buttons`
- `fix: resolved overflow issue on mobile`
- `docs: updated readme with setup instructions`

### 4. The PR Process (Pull Requests)

1. **Push your branch:** `git push origin feat/your-feature-name`
2. **Open PR:** Go to GitHub and click "Compare & pull request".
3. **Describe your changes:** Use the PR template to explain _what_ you did and _why_.
4. **Code Review:** Wait for a maintainer to review. Address any comments or requested changes.
5. **Merge:** Once approved, your code will be merged into `main`.

---

## 📂 Project Structure

```text
├── _server/               # NestJS Backend
│   ├── src/               # Application logic (Auth, Users, Prisma)
│   └── prisma/            # Database schema & migrations
├── lib/                   # Flutter Frontend
│   ├── features/          # Modular features (Auth, Chat, Student, Teacher)
│   ├── core/              # Shared constants, themes, and widgets
│   ├── models/            # Shared data models
│   └── routes/            # Application navigation
└── docs.md                # Detailed project documentation
```

---

## 🧪 Testing

### Backend

```bash
cd _server
npm run test        # Unit tests
npm run test:e2e    # End-to-end tests
```

### Frontend

```bash
flutter test
```

---

## 📄 License

This project is currently under development. Check with the repository owner for licensing terms.

**Happy Coding! and remember keep lerning**
