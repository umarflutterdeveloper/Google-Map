import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Googmap extends StatefulWidget {
  const Googmap({super.key});



  @override
  State<Googmap> createState() => _GoogmapState();
}

class _GoogmapState extends State<Googmap> {
  late BitmapDescriptor customIcon1;
  late BitmapDescriptor customIcon2;
  late BitmapDescriptor customIcon3;
  late BitmapDescriptor customIcon4;
  late BitmapDescriptor customIcon5;

  // Define a list of LatLng points for the polyline
  final List<LatLng> polylinePoints = [
    const LatLng(31.5313, 74.3183), // Marker 1
    const LatLng(31.3739, 74.3675), // Marker 2
    const LatLng(31.3523, 74.3734), // Marker 3
    const LatLng(31.3862, 74.3661), // Marker 4
    const LatLng(31.4109, 74.3631), // Marker 5
  ];
LatLng livelocation = LatLng(31.3739, 74.3675);
  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcons();
    _getCurrentLocation();

  }

  Future<BitmapDescriptor> _createCustomMarker(Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    // Drawing a custom shape, for example, a circle
    const double radius = 15;
    canvas.drawCircle(
      const Offset(radius, radius),
      radius,
      paint,
    );

    // Finalizing the canvas to convert it to an image
    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage((radius * 2).toInt(), (radius * 2).toInt());

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  void _setCustomMarkerIcons() async {
    // Create custom markers with different colors and shapes
    customIcon1 = await _createCustomMarker(Colors.blue);
    customIcon2 = await _createCustomMarker(Colors.green);
    customIcon3 = await _createCustomMarker(Colors.orange);
    customIcon4 = await _createCustomMarker(Colors.purple);
    customIcon5 = await _createCustomMarker(Colors.pink);

    // Ensure the state is updated after loading the custom icons
    setState(() {});
  }
  String _locationMessage = "";

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a message or prompt the user.
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message.
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, show a message.
      setState(() {
        _locationMessage =
        "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    }

    // When permissions are granted, get the current position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _locationMessage =
      "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      livelocation= LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(31.3739, 74.3675),
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('Marker1'),
            position: livelocation,
icon: customIcon1,
            infoWindow: const InfoWindow(
              title: 'Marker 1',
              snippet: 'This is the first custom marker',
            ),
          ),
        },
      ),
    );
  }
}
