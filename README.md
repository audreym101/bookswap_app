# BookSwap App

A Flutter application for swapping books between users with Firebase backend.

## Features

### 🔐 Authentication
- Email/password registration and login
- User profiles stored in Firestore
- Secure logout functionality

### 📚 Book Management
- **Create**: Add books with title, author, description, condition, and cover image
- **Read**: Browse all available books from other users
- **Update**: Manage your own book listings
- **Delete**: Remove your books from the marketplace

### 🔄 Swap System
- Request swaps on available books
- Accept/reject incoming swap requests
- Real-time status updates (pending/accepted/rejected)
- Track all your sent and received offers

### 💬 Chat System
- Real-time messaging between users
- Chat unlocks after swap request is accepted
- Message history stored in Firestore

### 📱 Navigation
- **Browse**: Discover books available for swap
- **My Books**: Manage your book listings
- **My Offers**: Track swap requests you've sent
- **Received**: Manage incoming swap requests
- **Settings**: Profile info and app preferences

## Technical Features

### 🖼️ Image Handling
- Base64 image storage (no Firebase Storage costs)
- Automatic compression on mobile devices
- Web and mobile compatibility
- Quality optimization (70% compression, max 800x800px)

### 🔥 Firebase Integration
- **Authentication**: User management
- **Firestore**: Real-time database for books, swaps, and messages
- **Real-time Updates**: Live sync across all devices

### 📱 Cross-Platform
- Flutter framework for iOS, Android, and Web
- Responsive design
- Platform-specific optimizations

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd bookswap_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Create a Firebase project
- Enable Authentication (Email/Password)
- Enable Firestore Database
- Add your `firebase_options.dart` file
- Add `google-services.json` for Android

4. **Run the app**
```bash
flutter run
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  image_picker: ^1.2.0
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.4.1
  shared_preferences: ^2.2.2
```

## Project Structure

```
lib/
├── models/
│   ├── book.dart
│   ├── user_profile.dart
│   └── swap_offer.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/
│   ├── auth_wrapper.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── browse_listings_screen.dart
│   ├── my_listings_screen.dart
│   ├── add_book_screen.dart
│   ├── my_offers_screen.dart
│   ├── received_offers_screen.dart
│   ├── chat_screen.dart
│   └── settings_screen.dart
└── main.dart
```

## Usage

1. **Sign Up/Login**: Create account or login with existing credentials
2. **Add Books**: Post books you want to swap with cover photos
3. **Browse**: Discover books from other users
4. **Request Swaps**: Send swap requests for books you want
5. **Manage Offers**: Accept/reject incoming requests in "Received" tab
6. **Chat**: Communicate with other users after swap acceptance

## Firebase Collections

### Books Collection
```json
{
  "title": "Book Title",
  "author": "Author Name",
  "description": "Book description",
  "condition": "Like New",
  "imageBase64": "base64_encoded_image",
  "ownerId": "user_uid",
  "ownerName": "username",
  "isAvailable": true,
  "createdAt": timestamp
}
```

### Swaps Collection
```json
{
  "bookId": "book_document_id",
  "bookTitle": "Book Title",
  "requesterId": "requester_uid",
  "requesterName": "requester_username",
  "ownerId": "owner_uid",
  "ownerName": "owner_username",
  "status": "pending|accepted|rejected",
  "createdAt": timestamp
}
```

### Users Collection
```json
{
  "uid": "user_uid",
  "email": "user@example.com",
  "displayName": "username",
  "emailVerified": true,
  "createdAt": timestamp
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.