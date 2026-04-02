---
title: Home
description: StudyApp — Peer-to-Peer Tutoring Marketplace
permalink: /
---

# 🎓 StudyApp

**Peer-to-Peer Tutoring Marketplace**

Connect students with expert tutors. Learn on your terms.

[📖 Read the Docs](docs) &nbsp;|&nbsp; [GitHub](https://github.com/hiyokun-d/study-app)

---

## What is StudyApp?

StudyApp is a modern, decoupled educational platform that connects **students** with **expert tutors**. Instead of rigid one-size-fits-all curriculums, StudyApp puts the learner in control — choose **what** to learn, **who** to learn from, and **when** to learn.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile / Web frontend | Flutter (Dart) |
| REST API backend | NestJS (TypeScript) |
| Database ORM | Prisma |
| Database | PostgreSQL (Supabase) |
| Authentication | JWT + Google OAuth |
| Testing | Jest (62 unit tests) |

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/hiyokun-d/study-app.git && cd study-app

# 2. Backend
cd _server && npm install && cp .env.example .env
# fill in .env, then:
npx prisma generate && npx prisma migrate deploy && npm run start:dev

# 3. Frontend (new terminal)
cd .. && flutter pub get && flutter run
```

---

## Features

| Feature | Description |
|---|---|
| 🔐 JWT Authentication | Secure login & registration |
| 🔑 Google Sign-In | One-tap OAuth login |
| 👨‍🏫 Tutor Profiles | Browse and connect with tutors |
| 🎓 Student Dashboard | Track learning and sessions |
| 💬 Chat | Direct messaging |
| 📦 Subscriptions | Flexible learning plans |
| 📱 Cross-platform | Android, iOS, Web |

---

## API Endpoints at a Glance

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/signup` | — | Register |
| `POST` | `/auth/login` | — | Login |
| `POST` | `/auth/google` | — | Google OAuth |
| `GET` | `/user/tutors` | — | Browse tutors |
| `GET` | `/user/tutor/:id` | — | Tutor detail |
| `PATCH` | `/user/update/profile` | 🔒 | Update profile |

See the [full API reference](docs#7-api-reference) in the docs.

---

## Contributors

[![Contributors](https://contrib.rocks/image?repo=hiyokun-d/study-app)](https://github.com/hiyokun-d/study-app/graphs/contributors)
