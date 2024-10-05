import 'package:flutter/foundation.dart'; // Importing foundation to use ChangeNotifier for state management

// LocationProvider class for managing the location state
class LocationProvider with ChangeNotifier {
  // Private variable to store the location
  String _location = '';

  // Getter to access the current location
  String get location => _location;

  // Setter to update the location and notify listeners about the change
  void setLocation(String newLocation) {
    _location = newLocation; // Updating the location
    notifyListeners(); // Notifying all listeners (widgets) about the change in state
  }
}
