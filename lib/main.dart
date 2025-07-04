import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepVibe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartScreen(),
    );
  }
}

/// 1. Startscreen mit Logo und Start-Button
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 120),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PermissionScreen()),
                  );
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. Permissionscreen: fragt Location- und Bewegungssensor-Permissions ab
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  Future<void> _requestPermissions() async {
    // Standort-Permission
    final locStatus = await Permission.locationWhenInUse.request();
    // Activity-Recognition-Permission
    final actStatus = await Permission.activityRecognition.request();

    if (locStatus.isGranted && actStatus.isGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      // zurück zum Start
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_requestPermissions);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'StepVibe benötigt Zugriff auf Standort- und Bewegungssensoren.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// 3. MainPage: Bewegung ja/nein, Intervalleingabe, Vibrieren, Stop-Button
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _moving = false;
  double _totalDistance = 0;
  double _bufferDistance = 0;
  int _vibrationCount = 0;
  int _intervalMeters = 100;

  late final TextEditingController _intervalController;
  StreamSubscription<Position>? _positionSub;
  Position? _lastPos;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(text: '$_intervalMeters');

    // Location-Updates starten
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position pos) {
    if (_lastPos != null) {
      final inc = Geolocator.distanceBetween(
        _lastPos!.latitude,
        _lastPos!.longitude,
        pos.latitude,
        pos.longitude,
      );
      _totalDistance += inc;
      _bufferDistance += inc;

      // Bewegung erkannt, wenn Geschwindigkeit > 0.5 m/s
      _moving = pos.speed > 0.5;

      // prüfen, ob wir vibrieren müssen
      if (_bufferDistance >= _intervalMeters) {
        _vibrationCount++;
        // Debug-Ausgabe vor der Vibration
        print('🔔 Vibration #$_vibrationCount ausgelöst bei Gesamtdistanz '
              '${_totalDistance.toStringAsFixed(0)} m');
        Vibration.vibrate(duration: 200);
        _bufferDistance = 0;
      }

      setState(() {});
    }
    _lastPos = pos;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StepVibe')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bewegung erkannt: ${_moving ? "Ja" : "Nein"}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Vibrationsintervall (Meter):'),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (s) {
                      final v = int.tryParse(s);
                      if (v != null && v > 0) {
                        _intervalMeters = v;
                      }
                    },
                  ),
                ),  
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ResultPage(
                      distanceMeters: _totalDistance,
                      vibrationCount: _vibrationCount,
                    ),
                  ),
                );
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. Ergebnisseite mit gelaufener Distanz und Vibrationen
class ResultPage extends StatelessWidget {
  final double distanceMeters;
  final int vibrationCount;
  const ResultPage({
    super.key,
    required this.distanceMeters,
    required this.vibrationCount,
  });

  @override
  Widget build(BuildContext context) {
    final km = (distanceMeters / 1000).toStringAsFixed(2);
    final m = distanceMeters.toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Distanz: $m m  ($km km)',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Anzahl Vibrationen: $vibrationCount',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
