import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Photo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  Position? _currentPosition;
  GoogleMapController? _mapController;

  final ImagePicker _picker = ImagePicker();

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      ),
    );
  }

  Future<void> _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geo Photo App'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Text('No image selected.')
                  : Image.file(File(_image!.path)),
              SizedBox(height: 20),
              _currentPosition == null
                  ? Text('No location selected.')
                  : Text(
                      'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}'),
              SizedBox(height: 20),
              _currentPosition == null
                  ? Container()
                  : Container(
                      height: 300,
                      width: 300,
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              15,
                            ),
                          );
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 2,
                        ),
                        markers: _currentPosition != null
                            ? {
                                Marker(
                                  markerId: MarkerId('currentLocation'),
                                  position: LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                ),
                              }
                            : {},
                      ),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('toma una Photo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Obtener Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
