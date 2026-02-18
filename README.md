# Attendance App - Flutter

Flutter mobile app for the Attendance Management System API.

## 🚀 Features
- ✅ JWT Authentication (Login / Register)
- ✅ GPS Location capture
- ✅ Selfie verification (Camera / Gallery)
- ✅ Mark Check-In with geolocation
- ✅ Mark Check-Out with geolocation
- ✅ Personal attendance summary with date filters
- ✅ Admin panel (summary + PDF export + user list)
- ✅ Role-based access (admin sees extra features)
- ✅ GetX state management
- ✅ Beautiful UI with Poppins font

## 📁 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # API URLs, storage keys, roles
│   ├── theme/
│   │   └── app_theme.dart           # Colors, text styles, theme
│   ├── utils/
│   │   └── app_utils.dart           # Formatters, validators, snackbars
│   └── routes.dart                  # GetX navigation routes
├── models/
│   └── models.dart                  # All data models
├── services/
│   ├── api_service.dart             # HTTP API calls
│   ├── storage_service.dart         # SharedPreferences storage
│   └── location_service.dart        # GPS location
├── controllers/
│   ├── auth_controller.dart         # Login/Register/Logout logic
│   ├── attendance_controller.dart   # Mark-In/Out + Summary
│   └── admin_controller.dart        # Admin Summary + Users
└── screens/
    ├── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── attendance/
    │   ├── home_screen.dart
    │   ├── mark_attendance_screen.dart  # Used for both check-in/check-out
    │   └── user_summary_screen.dart
    └── admin/
        └── admin_screen.dart
```

## ⚙️ Setup

### 1. Set API Base URL
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com'; // Change this!
```

### 2. Add Fonts
Download Poppins font from Google Fonts and add to `assets/fonts/`:
- Poppins-Regular.ttf
- Poppins-Medium.ttf
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf

### 3. Create Asset Folders
```bash
mkdir -p assets/images assets/lottie assets/fonts
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run
```bash
flutter run
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `get` | State management + navigation |
| `http` | API calls |
| `shared_preferences` | Token/user data storage |
| `geolocator` | GPS location |
| `image_picker` | Camera/gallery selfie |
| `permission_handler` | Runtime permissions |
| `intl` | Date formatting |

## 🔧 Android Permissions Required
- `INTERNET` - API calls
- `ACCESS_FINE_LOCATION` - GPS
- `CAMERA` - Selfie
- `READ_MEDIA_IMAGES` - Gallery

## 📱 Screens

| Screen | Route | Access |
|--------|-------|--------|
| Splash | `/` | All |
| Login | `/login` | All |
| Register | `/register` | All |
| Home | `/home` | Logged in |
| Check In | `/mark-in` | Logged in |
| Check Out | `/mark-out` | Logged in |
| My Summary | `/user-summary` | Logged in |
| Admin Panel | `/admin` | Admin only |

## 🎨 Design

- **Primary Color**: Blue (#2563EB)
- **Font**: Poppins
- **Design**: Material 3
- **Architecture**: MVC with GetX

## ⚠️ Important Notes

1. Change `baseUrl` in `app_constants.dart` to your actual server URL
2. For HTTP (not HTTPS), `android:usesCleartextTraffic="true"` is already set in manifest
3. Admin features are automatically shown for users with `admin` role
4. Date range is limited to 31 days (as per API)

---

**Version**: 1.0.0  
**API Version**: 2.0  
**Min SDK**: Android 5.0 (API 21)
