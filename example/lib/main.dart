import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String address = "null";
  String autocompletePlace = "null";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('location picker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Google Map Location Picker\nMade By Arvind 😃 with Flutter 🚀",
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              child: const Text('Pick location'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapLocationPicker(
                        apiKey: "API_KEY_HERE",
                        canPopOnNextButtonTaped: true,
                        onNext: (GeocodingResult? result) {
                          if (result != null) {
                            setState(() {
                              address = result.formattedAddress ?? "";
                            });
                          }
                        },
                        onSuggestionSelected: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              autocompletePlace =
                                  result.result.formattedAddress ?? "";
                            });
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: Text("Geocoded Address: $address"),
          ),
          ListTile(
            title: Text("Autocomplete Address: $autocompletePlace"),
          ),
          const Spacer(
            flex: 3,
          ),
        ],
      ),
    );
  }
}
