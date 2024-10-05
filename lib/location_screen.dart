// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Importing Flutter Map package for map integration
import 'package:latlong2/latlong.dart'; // Importing LatLng to handle geographical coordinates
import 'package:provider/provider.dart'; // Importing Provider for state management
import 'package:geocoding/geocoding.dart'; // Importing Geocoding package to convert address to coordinates
import 'package:geolocator/geolocator.dart'; // Importing Geolocator to get current device location
import 'location_provider.dart'; // Importing LocationProvider to manage location state

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController =
      MapController(); // Controller for managing map interactions
  LatLng? _center; // Center of the map, based on the user's entered location
  LatLng? _userLocation; // Current device location of the user
  bool _isLoading =
      true; // Loading state to show a progress indicator while fetching data

  @override
  void initState() {
    super.initState();
    _getLocationCoordinates(); // Get coordinates for the entered location
    _getCurrentLocation(); // Fetch the current location of the user
  }

  // Method to get coordinates from the user's entered location
  Future<void> _getLocationCoordinates() async {
    final locationProvider = Provider.of<LocationProvider>(context,
        listen: false); // Access the location from LocationProvider
    final location = locationProvider.location;

    try {
      // Use Geocoding to get the coordinates from the entered address
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        setState(() {
          _center = LatLng(
              locations.first.latitude,
              locations
                  .first.longitude); // Set map center to the found coordinates
          _isLoading = false; // Loading completed
        });
      }
    } catch (e) {
      _showErrorSnackBar(
          context, 'Error getting location coordinates: ${e.toString()}');
      setState(() {
        _isLoading = false; // Ensure loading is stopped in case of errors
      });
    }
  }

  // Method to get the current GPS location of the user
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar(context, 'Location services are disabled.');
        return;
      }

      // Check and request permission to access the location
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar(context, 'Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(
            context, 'Location permissions are permanently denied.');
        return;
      }

      // Get the current position of the device
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude,
            position.longitude); // Store the user's current location
      });
    } catch (e) {
      _showErrorSnackBar(
          context, 'Error getting current location: ${e.toString()}');
    }
  }

  // Method to show a SnackBar with an error message
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner if data is still being fetched
          : _center == null
              ? const Center(
                  child: Text(
                      'Unable to load the map. Please try again.')) // Show error if no coordinates were found
              : FlutterMap(
                  mapController: _mapController, // Control map behavior
                  options: MapOptions(
                    initialCenter:
                        _center!, // Set the map's initial center to the user's entered location
                    initialZoom: 13.0, // Initial zoom level for the map
                  ),
                  children: [
                    // Layer for rendering the map tiles using OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Marker layer for displaying markers on the map
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _center!, // Mark the user's entered location
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                        if (_userLocation != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point:
                                _userLocation!, // Mark the user's current location
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
      // Floating action button to move the map to the user's current location
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userLocation != null) {
            _mapController.move(_userLocation!,
                15); // Move map to user's current location with zoom level 15
          } else {
            _showErrorSnackBar(context,
                'Unable to move to current location. Location not available.');
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
