// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart'; // Importing pretty animated buttons package for styled buttons
import 'package:provider/provider.dart'; // Importing Provider for state management
import 'package:ridesense_location_app/location_screen.dart'; // Importing LocationScreen for navigation to the next screen
import 'location_provider.dart'; // Importing LocationProvider to handle location state management

// LocationInputScreen widget allows users to input their desired location and navigate to the next screen
class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _locationController =
      TextEditingController(); // Controller to handle location input
  final _formKey = GlobalKey<FormState>(); // Key for the form to validate input

  // Function to show an error message in a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // Display error message
        backgroundColor: Colors.red, // Set background color to red for errors
      ),
    );
  }

  // Function to validate input and navigate to the next screen
  Future<void> _navigateToNextScreen(BuildContext context) async {
    // Validate the form before proceeding
    if (_formKey.currentState!.validate()) {
      try {
        // Update the location in the provider and navigate to the next screen
        Provider.of<LocationProvider>(context, listen: false)
            .setLocation(_locationController.text);

        // Navigate to the next screen, passing the entered location
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NextScreen(location: _locationController.text),
          ),
        );
      } catch (e) {
        // Show error message if an exception occurs
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Scroll view to ensure content is scrollable on smaller devices
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the content horizontally
            children: [
              const SizedBox(height: 90), // Spacer for layout
              Image.asset(
                'assets/images/ridesense.png', // Ridesense logo image
                height: 300, // Set image height
                fit: BoxFit.contain, // Ensure image fits within bounds
                errorBuilder: (context, error, stackTrace) {
                  // Handle image load errors gracefully
                  _showErrorSnackBar(
                      'Failed to load image: ${error.toString()}');
                  return const Icon(
                      Icons.error); // Show error icon if image fails to load
                },
              ),
              const SizedBox(height: 40), // Spacer between image and form
              Form(
                key: _formKey, // Assign form key for validation
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align form fields to the left
                  children: <Widget>[
                    const Center(
                      // Title for the input field
                      child: Text(
                        'Enter your Desired Location ',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Spacer before the input field
                    TextFormField(
                      controller:
                          _locationController, // Link the controller to input field
                      decoration: const InputDecoration(
                        labelText: 'Location', // Label for the input field
                        hintText:
                            'Enter city name, address, or coordinates', // Placeholder hint
                        border:
                            OutlineInputBorder(), // Input field border style
                      ),
                      validator: (value) {
                        // Validation logic for empty input
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location'; // Error message if no input
                        }
                        return null; // Input is valid
                      },
                    ),
                    const SizedBox(height: 20), // Spacer before the button
                    Center(
                      child: PrettyWaveButton(
                        // Styled button to navigate to the next screen
                        onPressed: () => _navigateToNextScreen(context),
                        child: const Text('Next',
                            style:
                                TextStyle(color: Colors.white)), // Button label
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed to avoid memory leaks
    _locationController.dispose();
    super.dispose();
  }
}

// NextScreen widget to display the location screen with the user's input
class NextScreen extends StatelessWidget {
  final String location; // The location input from the previous screen

  const NextScreen({required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    // Simply return the LocationScreen for now
    return const LocationScreen();
  }
}
