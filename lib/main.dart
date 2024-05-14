import 'package:flutter/material.dart';
import 'package:mapbox_map/pages/main-page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      "sk.eyJ1IjoiaGFzaGlyMTIiLCJhIjoiY2x3NTh3MHR0MWdzcjJrcGhhMDBranQ4MSJ9.wL2w6LHqUQC2TrF0uKs9fw");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
