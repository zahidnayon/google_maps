import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Location _location = Location();
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Marker _marker = Marker(markerId: MarkerId("currentLocation"));

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _updatePolyline(LatLng newPosition) {
    setState(() {
      _polylineCoordinates.add(newPosition);
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId("poly"),
          color: Colors.blue,
          points: _polylineCoordinates,
        ),
      );
    });
  }

  void _updateMarker(LatLng newPosition) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("currentLocation"),
        position: newPosition,
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('My current location'),
                      Text(
                        'Lat: ${newPosition.latitude.toStringAsFixed(6)}, Lng: ${newPosition.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen((locationData) {
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLng(
            LatLng(locationData.latitude!, locationData.longitude!)));
        _updatePolyline(
            LatLng(locationData.latitude!, locationData.longitude!));
        _updateMarker(
            LatLng(locationData.latitude!, locationData.longitude!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map App')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 15,
        ),
        myLocationEnabled: true,
        markers: {_marker},
        polylines: _polylines,
      ),
    );
  }
}
