import 'package:flutter/material.dart';
import 'package:mapbox_map/pages/point-annotation-page.dart';
import 'package:mapbox_map/pages/polygon-annotation.page.dart';
import 'package:mapbox_map/pages/polyline-annotation-page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapbox Map Implementation!"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PointAnnotationPageBody()));
                },
                child: const Text("Point")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const PolylineAnnotationPageBody()));
                },
                child: const Text("Line")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PolygonAnnotationPageBody()));
                },
                child: const Text("Polygon")),
          ],
        ),
      ),
    );
  }
}
