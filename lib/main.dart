import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? mapController; // Controlador para Google Map
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  // Inicializa la posición del mapa en un lugar por defecto (puede ser tu ubicación actual o cualquier otra)
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Localizador de Estacionamiento'),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _currentPosition != null
              ? CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 14)
              : _initialPosition,
          markers: _markers,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _getCurrentLocation,
          tooltip: 'Marcar Estacionamiento',
          child: Icon(Icons.local_parking),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('mi_estacionamiento'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Mi Estacionamiento', snippet: 'Aquí estacioné mi coche.'),
        ),
      );
      mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
    });
  }
}