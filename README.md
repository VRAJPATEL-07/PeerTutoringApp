# Smart Peer Tutoring & Session Matching App

Flutter application for peer tutoring with tutor matching, session scheduling, session tracking, feedback/rating, and offline-first local data storage with backend synchronization.

## Features Implemented

- User Profile Module
	- Name, Role (Tutor/Learner/Both), Subjects, Skill Level, Availability
- Tutor Matching Module
	- Match by subject, availability slot, and skill compatibility
	- Search by tutor name or subject
	- Filter by minimum rating and skill level
- Session Scheduling Module
	- Book session with date/time and subject
	- Auto-generates unique Session ID
	- Prevents duplicate tutor bookings at same time
- Session Management Module
	- Upcoming / Completed / Cancelled tabs
	- Status updates: Scheduled -> Completed/Cancelled
- Feedback & Rating Module
	- Submit rating (1-5) and optional feedback comments
- Offline Functionality
	- Hive local storage for profiles and sessions
	- Auto-syncs when online
- Backend Sync
	- Node.js + Express + MongoDB (Compass compatible)
	- `/api/sync` endpoint upserts profiles and sessions

## Screens

1. User Profile Setup Screen
2. Tutor Listing/Matching Screen
3. Session Booking Screen
4. Session Management Screen
5. Feedback & Rating Screen

## Tech Stack

- Flutter
- Provider (state management)
- Hive (offline local storage)
- Connectivity Plus (network check)
- HTTP (sync API calls)
- Node.js + Express + MongoDB (backend)

## Project Structure

- `lib/models` - enums and data models
- `lib/providers` - app-wide state and business logic
- `lib/services` - matching, storage, sync services
- `lib/screens` - UI screens
- `backend` - MongoDB backend API

## Run Frontend (Flutter)

From project root:

```bash
flutter pub get
flutter run -d chrome
```

## Run Backend (MongoDB + Express)

1. Open MongoDB Compass and ensure local MongoDB is available at `mongodb://127.0.0.1:27017`.
2. In terminal:

```bash
cd backend
copy .env.example .env
npm install
npm run dev
```

The backend runs at `http://localhost:4000` and Flutter syncs to this URL.

## API

- `GET /api/health`
- `POST /api/sync`
	- Body:
		- `profiles`: list of user profiles
		- `sessions`: list of tutoring sessions

## Matching Logic Summary

- Tutor must have tutor capability (`Tutor` or `Both`)
- Tutor must teach selected subject
- Tutor skill must be >= learner required skill
- Optional filters: availability, minimum rating, search text
- Booking validation:
	- session must be in future
	- tutor must be available for selected slot
	- no duplicate booking for same tutor at same date-time

## Notes

- App works offline using Hive and syncs later when backend is available.
- If backend is not running, app continues to work locally and shows sync status message.
