# Flashcards App - Anki Clone

A comprehensive offline-first flashcard application built with Flutter that mimics Anki's core features.

## Features

### ✅ Implemented Features

1. **Offline-First Architecture**
   - All data stored locally in SQLite
   - Works without internet connection
   - Background sync when online

2. **Collection Management**
   - Create, edit, and delete collections
   - Organize cards into collections
   - View card counts and due cards per collection

3. **Flashcard Management**
   - Create and edit text-based flashcards
   - Simple front/back card design
   - Delete cards with confirmation

4. **Spaced Repetition (SM-2 Algorithm)**
   - Intelligent card scheduling based on the SM-2 algorithm
   - Four difficulty ratings: Wrong, Hard, Good, Easy
   - Automatic interval calculation
   - Review tracking and history

5. **Study Features**
   - Study all cards or specific collections
   - Visual progress tracking
   - Configurable daily review limits
   - Review statistics

6. **Backend Synchronization**
   - Queue-based sync system
   - Last Write Wins conflict resolution
   - Automatic retry on failure
   - Sync status indicators

7. **Authentication**
   - User registration and login
   - JWT token-based authentication
   - Persistent sessions

8. **Import/Export**
   - Export collections to JSON
   - Import collections from JSON
   - Bulk export/import support

9. **Settings**
   - Maximum reviews per day
   - Maximum new cards per day
   - Show answer timer option
   - Account information

## Project Structure

### Flutter App
```
lib/
├── database/
│   └── database_helper.dart       # SQLite database setup
├── models/
│   ├── card_model.dart            # Card data model
│   ├── collection_model.dart      # Collection data model
│   ├── review_log.dart            # Review history model
│   ├── study_settings.dart        # User settings model
│   ├── sync_queue_item.dart       # Sync queue model
│   └── user_model.dart            # User data model
├── providers/
│   ├── auth_provider.dart         # Authentication state
│   ├── card_provider.dart         # Card management state
│   ├── collection_provider.dart   # Collection management state
│   ├── settings_provider.dart     # Settings state
│   └── study_provider.dart        # Study session state
├── repositories/
│   ├── card_repository.dart       # Card data access
│   ├── collection_repository.dart # Collection data access
│   ├── review_log_repository.dart # Review log data access
│   ├── settings_repository.dart   # Settings data access
│   ├── sync_repository.dart       # Sync queue data access
│   └── user_repository.dart       # User data access
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── cards/
│   │   └── card_editor_screen.dart
│   ├── collections/
│   │   └── collections_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   ├── study/
│   │   └── study_session_screen.dart
│   ├── home_screen.dart
│   └── splash_screen.dart
├── services/
│   ├── auth_service.dart          # Authentication API
│   ├── import_export_service.dart # Import/Export functionality
│   ├── spaced_repetition_service.dart # SM-2 algorithm
│   └── sync_service.dart          # Sync management
└── main.dart
```

### Backend API
```
backend/
├── app/
│   ├── core/
│   │   ├── config.py              # Settings management
│   │   ├── database.py            # Database setup
│   │   └── security.py            # Auth utilities (JWT, hashing)
│   ├── models/
│   │   └── models.py              # SQLAlchemy models
│   ├── schemas/
│   │   └── schemas.py             # Pydantic schemas
│   ├── routers/
│   │   ├── auth.py                # Authentication endpoints
│   │   ├── collections.py         # Collection CRUD
│   │   ├── cards.py               # Card CRUD
│   │   ├── review_logs.py         # Review log endpoints
│   │   └── sync.py                # Sync endpoint
│   └── main.py                    # FastAPI application
├── venv/                          # Virtual environment
├── .env                           # Environment variables
├── .env.example                   # Example configuration
├── requirements.txt               # Python dependencies
├── run.sh                         # Start script
├── README.md                      # Backend documentation
└── QUICKSTART.md                  # Quick start guide
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Python 3.13+ (for backend)

### Backend Setup

The backend is built with FastAPI and is located in the `backend/` directory.

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. The virtual environment is already set up. Start the server:
   ```bash
   ./run.sh
   ```
   
   Or manually:
   ```bash
   venv/bin/python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

3. The API will be available at:
   - API: http://localhost:8000
   - Interactive docs: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc

For detailed backend documentation, see [backend/README.md](backend/README.md) and [backend/QUICKSTART.md](backend/QUICKSTART.md).

### Flutter App Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation for JSON serialization:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Update the backend URL in the services if needed (default is http://localhost:8000)

5. Run the app:
   ```bash
   flutter run
   ```

## Testing on Physical Devices

If you're testing on a physical device:

1. Find your computer's IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```

2. Update the backend URL in Flutter services:
   - Replace `localhost` with your IP address (e.g., `http://192.168.1.100:8000`)
   - Files to update:
     - `lib/services/auth_service.dart`
     - `lib/services/sync_service.dart`

3. Ensure your device and computer are on the same network

## Backend API

The backend is a fully functional FastAPI application located in the `backend/` directory. It provides:

### Features
- JWT-based authentication
- RESTful API for collections, cards, and review logs
- Offline-first sync support with conflict resolution
- SQLite database (easily swappable for PostgreSQL)
- Automatic API documentation (Swagger/ReDoc)
- CORS support for mobile app integration

### Quick Start
```bash
cd backend
./run.sh
```

Visit http://localhost:8000/docs for interactive API documentation.

### API Endpoints

#### Authentication
- `POST /api/auth/register` - Register a new user
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "display_name": "John Doe"
  }
  ```
- `POST /api/auth/login` - Login user (returns JWT token)
- `GET /api/auth/me` - Get current user info (requires auth)

#### Collections
- `GET /api/collections?since={timestamp}` - Get collections modified after timestamp
- `GET /api/collections/{id}` - Get specific collection
- `POST /api/collections` - Create/update collection
- `PUT /api/collections/{id}` - Update collection (for sync)
- `DELETE /api/collections/{id}` - Soft delete collection

#### Cards
- `GET /api/cards?collection_id={id}&since={timestamp}` - Get cards
- `GET /api/cards/{id}` - Get specific card
- `POST /api/cards` - Create card
- `PUT /api/cards/{id}` - Update card (including spaced repetition data)
- `DELETE /api/cards/{id}` - Soft delete card

#### Review Logs
- `GET /api/review-logs?card_id={id}&since={timestamp}` - Get review history
- `POST /api/review-logs` - Create review log

#### Sync
- `POST /api/sync` - Sync endpoint for offline-first architecture
  - Accepts local changes (collections, cards, review logs)
  - Returns server changes since last sync
  - Implements Last Write Wins conflict resolution

### Database Schema

The backend uses SQLAlchemy ORM with the following models:

- **User**: Authentication and user data
- **Collection**: Card collections with soft delete support
- **Card**: Flashcards with SM-2 spaced repetition fields
- **ReviewLog**: Review history for analytics

All models include:
- `version` field for optimistic locking
- `updated_at` timestamp for sync
- `is_deleted` flag for soft deletes

### Configuration

The backend URL in the Flutter app can be configured in:
- `lib/services/auth_service.dart` - Line 8
- `lib/services/sync_service.dart` - Line 13

Default: `http://localhost:8000/api`

For more details, see [backend/README.md](backend/README.md).

## Key Technologies

### Frontend (Flutter)
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **SQLite (sqflite)** - Local database
- **JSON Serialization** - Data serialization
- **HTTP** - API communication
- **Shared Preferences** - Token storage
- **File Picker** - Import/export functionality

### Backend (FastAPI)
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **Pydantic** - Data validation and schemas
- **JWT (python-jose)** - Token-based authentication
- **Passlib** - Password hashing
- **Uvicorn** - ASGI server
- **SQLite** - Development database (PostgreSQL ready)

## Spaced Repetition Algorithm (SM-2)

The app uses the SM-2 algorithm with the following intervals:

- **First repetition**: 1 day
- **Second repetition**: 6 days
- **Subsequent repetitions**: Previous interval × Ease Factor

Ease factor adjusts based on user performance:
- **Wrong (0)**: Reset card, restart learning
- **Hard (3)**: Reduce interval by 25%
- **Good (4)**: Standard interval
- **Easy (5)**: Increase interval by 30%

## Data Models

### Card
- Front/Back text
- Ease factor (default: 2.5)
- Interval (days)
- Repetitions count
- Next review date
- Review history

### Collection
- Name
- Description
- Card count
- Created/Updated timestamps

### Study Settings
- Max reviews per day (default: 100)
- Max new cards per day (default: 20)
- Show answer timer
- Auto-play audio (for future use)

## Sync Strategy

1. **Queue Local Changes**: All create/update/delete operations are queued
2. **Push Phase**: Send queued changes to backend
3. **Pull Phase**: Fetch remote changes since last sync
4. **Conflict Resolution**: Last Write Wins based on `updated_at` timestamp
5. **Retry Logic**: Failed syncs retry up to 5 times

## Future Enhancements

- [ ] Audio/Image support for cards
- [ ] Statistics and analytics dashboard
- [ ] Multiple card templates
- [ ] Tags and filtering
- [ ] Shared decks
- [ ] Dark mode
- [ ] Widgets for quick study
- [ ] Cloud backup
- [ ] Collaborative decks
- [ ] PostgreSQL support for production
- [ ] Docker deployment

## Contributing

This is an educational project demonstrating:
- Offline-first mobile architecture
- Spaced repetition algorithms
- Flutter + FastAPI integration
- State management with Provider
- RESTful API design
- JWT authentication
- Database synchronization

Feel free to use this as a learning resource or starting point for your own projects.

## License

This project is open source and available for educational purposes.
