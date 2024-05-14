import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PointAnnotationPageBody extends StatefulWidget {
  const PointAnnotationPageBody({super.key});

  @override
  State<StatefulWidget> createState() => PointAnnotationPageBodyState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
  }
}

class PointAnnotationPageBodyState extends State<PointAnnotationPageBody> {
  PointAnnotationPageBodyState();
  Future<geo.Position> getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition();
    return position;
  }

  MapboxMap? mapboxMap;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;
  int styleIndex = 1;
  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    geo.Position position = await getCurrentLocation();

    mapboxMap.setCamera(CameraOptions(
        center:
            Point(coordinates: Position(position.longitude, position.latitude))
                .toJson(),
        zoom: 3,
        pitch: 0));
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      final ByteData bytes = await rootBundle.load('assets/marker.png');
      final Uint8List list = bytes.buffer.asUint8List();
      createOneAnnotation(
        list,
        0.381457,
        6.687337,
      );
      var options = <PointAnnotationOptions>[];
      for (var i = 0; i < 5; i++) {
        options.add(PointAnnotationOptions(
            geometry: createRandomPoint().toJson(), image: list));
      }
      pointAnnotationManager?.createMulti(options);

      var carOptions = <PointAnnotationOptions>[];
      for (var i = 0; i < 20; i++) {
        carOptions.add(PointAnnotationOptions(
            geometry: createRandomPoint().toJson(), iconImage: "car-15"));
      }
      pointAnnotationManager?.createMulti(carOptions);
      pointAnnotationManager
          ?.addOnPointAnnotationClickListener(AnnotationClickListener());
    });
  }

  void createOneAnnotation(Uint8List list, lat, lng) {
    pointAnnotationManager
        ?.create(PointAnnotationOptions(
            geometry: Point(coordinates: Position(lat, lng)).toJson(),
            textField: "custom-icon",
            textOffset: [0.0, -2.0],
            textColor: Colors.red.value,
            iconSize: 1.3,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list))
        .then((value) => pointAnnotation = value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void createPoint(coordinates) async {
    final ByteData bytes = await rootBundle.load('assets/marker.png');
    final Uint8List list = bytes.buffer.asUint8List();
    var lat = coordinates == null ? 0.381457 : coordinates.y;
    var lng = coordinates == null ? 6.687337 : coordinates.x;
    print("Hello!@$lat");
    createOneAnnotation(list, lat, lng);
  }

  Widget _deleteAll() {
    return TextButton(
      child: const Text('delete all point annotations'),
      onPressed: () {
        pointAnnotationManager?.deleteAll();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      onTapListener: (coordinate) {
        print("Hello");
        createPoint(coordinate);
      },
    );

    final List<Widget> listViewChildren = <Widget>[];

    listViewChildren.addAll(
      <Widget>[_deleteAll(), const BackButton()],
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
          child: ListView(
            children: listViewChildren,
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
              const SizedBox(height: 10),
            ],
          ),
        ),
        body: colmn);
  }
}

Point createRandomPoint() {
  return Point(coordinates: createRandomPosition());
}

Position createRandomPosition() {
  var random = Random();
  return Position(random.nextDouble() * -360.0 + 180.0,
      random.nextDouble() * -180.0 + 90.0);
}
