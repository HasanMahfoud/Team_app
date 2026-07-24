# 🎓 University Guide — Premium Flutter App

## Folder Structure

```
lib/
├── main.dart                          ← Entry point, app config, immersive UI
│
├── core/
│   └── theme/
│       └── app_theme.dart             ← Colors, gradients, shadows, Material 3 theme
│
├── models/
│   └── college.dart                   ← College model + shared static data
│
└── features/
    ├── shell/
    │   └── shell_screen.dart          ← Navigation shell + premium BottomNavBar
    │
    ├── home/
    │   └── home_screen.dart           ← Premium home with hero, stats, cards, news
    │
    ├── map/
    │   └── map_screen.dart            ← Map with markers, controls, college panel
    │
    ├── notifications/
    │   └── notifications_screen.dart  ← Filterable, dismissible notification cards
    │
    └── profile/
        └── profile_screen.dart        ← Full profile with stats, academic info, settings
```

---

## Design Decisions

### BottomNavBar — Glassmorphism Floating Pill
- `BackdropFilter` + white overlay = true glass blur effect
- Animated pill background expands on active tab (AnimatedContainer)
- Icon bounce via TweenSequence (scale 1.0 → 1.35 → 1.0 with elasticOut)
- Animated dot indicator underneath active label
- Floats above content with `extendBody: true`

### Home Screen
- Staggered entrance animations (FadeTransition + SlideTransition)
- Hero banner with gradient + decorative circles
- Stats cards with colored icon containers
- College horizontal scroll with per-card staggered reveal
- News cards with InkWell ripple and arrow CTA

### Map Screen
- CustomPainter map grid (swap for FlutterMap — integration comment included)
- Pulsing user location marker (ScaleTransition loop)
- Satellite/normal toggle with AnimatedContainer
- College marker enlarges + shows label on selection
- Bottom panel animates between list view and detail view

### Notifications Screen
- Filter chips with animated active state
- Per-card staggered FadeTransition + SlideTransition
- Dismissible with red delete background
- Unread indicator dot + bold typography
- AnimatedSwitcher on filter change

### Profile Screen
- Gradient hero section with avatar ScaleTransition (elasticOut)
- 3-column stats row with dividers
- Academic info card with icon rows
- Settings with real Toggle switches (notifications, dark mode)
- Primary gradient CTA + danger logout button

---

## Activating Real flutter_map

In `map_screen.dart`, find the comment block:
```
// ── Real flutter_map integration point ──
```
Replace the `CustomPaint` with:
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(33.5138, 36.2765),
    initialZoom: 15.5,
  ),
  children: [
    TileLayer(
      urlTemplate: isSatellite
          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.university_guide',
    ),
    MarkerLayer(markers: _buildMarkers()),
    CurrentLocationLayer(), // from flutter_map_location_marker package
  ],
),
```

## Dependencies to run

```bash
flutter pub get
flutter run
```

For live location on Android, add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
