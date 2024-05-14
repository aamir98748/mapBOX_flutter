import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PolylineAnnotationPageBody extends StatefulWidget {
  const PolylineAnnotationPageBody({super.key});

  @override
  State<StatefulWidget> createState() => PolylineAnnotationPageBodyState();
}

class AnnotationClickListener extends OnPolylineAnnotationClickListener {
  @override
  void onPolylineAnnotationClick(PolylineAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
  }
}

class PolylineAnnotationPageBodyState
    extends State<PolylineAnnotationPageBody> {
  PolylineAnnotationPageBodyState();

  MapboxMap? mapboxMap;

  int count = 0;
  static List<Position> tapPositions = []; // Store tap coordinates
  PolylineAnnotation? polylineAnnotation;
  PolylineAnnotationManager? polylineAnnotationManager;
  int styleIndex = 1;

  Future<geo.Position> getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition();
    return position;
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.setCamera(CameraOptions(
        center: Point(coordinates: Position(0, 0)).toJson(),
        zoom: 1,
        pitch: 0));
    mapboxMap.annotations.createPolylineAnnotationManager().then((value) {
      polylineAnnotationManager = value;
      createOneAnnotation();
      final positions = <List<Position>>[];
      for (int i = 0; i < 99; i++) {
        positions.add(createRandomPositionList());
      }

      polylineAnnotationManager?.createMulti(positions
          .map((e) => PolylineAnnotationOptions(
              geometry: LineString(coordinates: e).toJson(),
              lineColor: createRandomColor()))
          .toList());
      polylineAnnotationManager
          ?.addOnPolylineAnnotationClickListener(AnnotationClickListener());
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void createOneAnnotation({List<Position>? positions}) {
    polylineAnnotationManager
        ?.create(PolylineAnnotationOptions(
            geometry: positions != null && positions != []
                ? LineString(coordinates: positions).toJson()
                : LineString(coordinates: [
                    Position(
                      1.0,
                      2.0,
                    ),
                    Position(
                      10.0,
                      20.0,
                    )
                  ]).toJson(),
            lineColor: Colors.red.value,
            lineWidth: 2))
        .then((value) => polylineAnnotation = value);
  }

  void _onMapTap(ScreenCoordinate screenCoordinate) async {
    if (count < 2) {
      tapPositions.add(Position(screenCoordinate.y, screenCoordinate.x));
      count = count + 1;
      print(count);
    }
    if (count == 2) {
      print(tapPositions.first);
      createOneAnnotation(positions: tapPositions);
      tapPositions.clear(); // Clear after drawing
      count = 0;
    }
  }

  Widget deleteAll() {
    return TextButton(
      child: const Text('delete all polyline annotations'),
      onPressed: () {
        polylineAnnotationManager?.deleteAll();
      },
    );
  }

  void createLineBetweenPoints() {
    if (tapPositions.length != 2) return;

    polylineAnnotationManager
        ?.create(PolylineAnnotationOptions(
            geometry: LineString(coordinates: tapPositions).toJson(),
            lineColor: Colors.red.value,
            lineWidth: 5))
        .then((value) {
      polylineAnnotation = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
        onTapListener: (coordinate) {
          _onMapTap(coordinate);
        },
        key: const ValueKey("mapWidget"),
        onMapCreated: _onMapCreated);

    final List<Widget> listViewChildren = <Widget>[];

    listViewChildren.addAll(
      <Widget>[
        deleteAll(),
        const Text("Press any 2 points on map to plot a line"),
        const BackButton()
      ],
    );

    final colmn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 400,
              child: mapWidget),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: listViewChildren,
            ),
          ),
        )
      ],
    );

    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
                    geo.Position position = await getCurrentLocation();
                    mapboxMap!.setCamera(CameraOptions(
                        center: Point(
                                coordinates: Position(
                                    position.longitude, position.latitude))
                            .toJson(),
                        zoom: 5,
                        pitch: 0));
                  },
                  child: const Icon(Icons.my_location_rounded)),
            ],
          ),
        ),
        body: colmn);
  }
}

Position createRandomPosition() {
  var random = Random();
  return Position(random.nextDouble() * -360.0 + 180.0,
      random.nextDouble() * -180.0 + 90.0);
}

List<Position> createRandomPositionList() {
  var random = Random();
  final positions = <Position>[];
  for (int i = 0; i < random.nextInt(6) + 4; i++) {
    positions.add(createRandomPosition());
  }

  return positions;
}

int createRandomColor() {
  var random = Random();
  return Color.fromARGB(
          255, random.nextInt(255), random.nextInt(255), random.nextInt(255))
      .value;
}
