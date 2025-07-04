# stepvibe

stepvibe is a Flutter mobile app that helps users track their walking distance, set vibration-based interval reminders, and review their activity summary. It guides the user through permission granting, real-time location tracking, and provides haptic feedback every set distance.

## Features

- **Permission flow**: Runtime requests for location and activity-recognition permissions  
- **Real-time tracking**: Uses Geolocator to stream position updates  
- **Haptic feedback**: Vibrates every configurable interval (default 100 m)  
- **Movement detection**: Indicates whether the user is moving (> 0.5 m/s)  
- **Result summary**: Displays total distance and number of vibrations  
- **Clean navigation**: Start → Permissions → Tracking → Results

## Tech Stack

- **Framework**: Flutter  
- **Permissions**: permission_handler  
- **Location & movement**: geolocator  
- **Vibration**: vibration  
- **Language**: Dart  

## Installation

1. **Clone the repo**  
   ```bash
   git clone https://github.com/yourusername/stepvibe.git
   cd stepvibe
````

2. **Install dependencies**

   ```bash
   flutter pub get
   ```
3. **Run on device or simulator**

   ```bash
   flutter run
   ```

## Usage

1. Tap **Start** on the splash screen
2. Grant **Location** and **Activity Recognition** permissions
3. Watch the **MainPage**:

   * See “Bewegung erkannt: Ja/Nein”
   * Adjust “Vibrationsintervall (Meter)” as desired
   * Tap **Stop** when finished
4. Review total distance and vibration count on the **ResultPage**
5. Tap **OK** to return to start

## Project Structure

```
lib/
├── main.dart             # App entry point & StartScreen
├── permission_screen.dart # PermissionScreen
├── main_page.dart        # MainPage with tracking & vibration logic
└── result_page.dart      # ResultPage summary
```

## License

This project is licensed under the MIT License.
