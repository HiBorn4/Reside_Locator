import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importing Provider package for state management
import 'location_provider.dart'; // Importing the LocationProvider class to manage location data
import 'home_page.dart'; // Importing the home page where users will input their location

void main() {
  runApp(
    // Wrapping the MyApp widget in a ChangeNotifierProvider to provide state management
    ChangeNotifierProvider(
      create: (context) =>
          LocationProvider(), // Creating an instance of LocationProvider to manage location state
      child: const MyApp(), // Running the main app
    ),
  );
}

// Main widget class for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disabling the debug banner
      title: 'Ridesense Location App', // Setting the title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Setting the app's primary color to blue
      ),
      home:
          const LocationInputScreen(), // Setting the starting screen as LocationInputScreen
    );
  }
}
