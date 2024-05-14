import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PolygonAnnotationPageBody extends StatefulWidget {
  const PolygonAnnotationPageBody({super.key});

  @override
  State<StatefulWidget> createState() => PolygonAnnotationPageBodyState();
}

class AnnotationClickListener extends OnPolygonAnnotationClickListener {
  AnnotationClickListener({
    required this.onAnnotationClick,
  });

  final void Function(PolygonAnnotation annotation) onAnnotationClick;

  @override
  void onPolygonAnnotationClick(PolygonAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
    onAnnotationClick(annotation);
  }
}

class PolygonAnnotationPageBodyState extends State<PolygonAnnotationPageBody> {
  PolygonAnnotationPageBodyState();

  MapboxMap? mapboxMap;
  PolygonAnnotation? polygonAnnotation;

  int count = 0;
  static List<Position> tapPositions = []; // Store tap coordinates
  PolygonAnnotationManager? polygonAnnotationManager;
  int styleIndex = 1;

  Future<geo.Position> getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition();
    return position;
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.setCamera(CameraOptions(
        center: Point(coordinates: Position(-3.363937, -10.733102)).toJson(),
        zoom: 1,
        pitch: 0));
    mapboxMap.annotations.createPolygonAnnotationManager().then((value) {
      polygonAnnotationManager = value;
      createOneAnnotation();
      var options = <PolygonAnnotationOptions>[];
      for (var i = 0; i < 2; i++) {
        options.add(PolygonAnnotationOptions(
            geometry:
                Polygon(coordinates: createRandomPositionsList()).toJson(),
            fillColor: createRandomColor()));
      }
      polygonAnnotationManager?.createMulti(options);
      polygonAnnotationManager?.addOnPolygonAnnotationClickListener(
        AnnotationClickListener(
          onAnnotationClick: (annotation) => polygonAnnotation = annotation,
        ),
      );
    });
  }

  void _onMapTap(ScreenCoordinate screenCoordinate) async {
    if (count < 4) {
      tapPositions.add(Position(screenCoordinate.y, screenCoordinate.x));
      count = count + 1;
      print(count);
    }
    if (count == 4) {
      print(tapPositions.first);
      createOneAnnotation(positions: [tapPositions]);
      tapPositions.clear(); // Clear after drawing
      count = 0;
    }
  }

  void createOneAnnotation({List<List<Position>>? positions}) {
    polygonAnnotationManager
        ?.create(PolygonAnnotationOptions(
            geometry: positions != null && positions != []
                ? Polygon(coordinates: positions).toJson()
                : Polygon(coordinates: [
                    [
                      Position(-3.363937, -10.733102),
                      Position(1.754703, -19.716317),
                      Position(-15.747196, -21.085074),
                      Position(-3.363937, -10.733102)
                    ]
                  ]).toJson(),
            fillColor: Colors.red.value,
            fillOutlineColor: Colors.purple.value))
        .then((value) => polygonAnnotation = value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _deleteAll() {
    return TextButton(
      child: const Text('delete all polygon annotations'),
      onPressed: () {
        polygonAnnotationManager?.deleteAll();
        polygonAnnotation = null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      onTapListener: (coordinate) {
        _onMapTap(coordinate);
      },
    );

    final List<Widget> listViewChildren = <Widget>[];

    listViewChildren.addAll(
      <Widget>[
        _deleteAll(),
        const Text("Press any 4 points on map to plot a polygon"),
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

List<List<Position>> createRandomPositionsList() {
  var random = Random();
  final first = createRandomPosition();
  final positions = <Position>[];
  positions.add(first);
  for (int i = 0; i < random.nextInt(6) + 4; i++) {
    positions.add(createRandomPosition());
  }
  positions.add(first);

  return [positions];
}
