import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:map_location_picker/generated/l10n.dart';
import 'package:map_location_picker/src/map.dart';
import 'package:map_location_picker/src/providers/location_provider.dart';
import 'package:map_location_picker/src/rich_suggestion.dart';
import 'package:map_location_picker/src/search_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../logger.dart';
import 'model/auto_comp_iete_item.dart';
import 'model/location_result.dart';
import 'model/nearby_place.dart';
import 'utils/location_utils.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker(
    this.apiKey, {
    Key? key,
    this.initialCenter = const LatLng(28.8993447, 76.6228793),
    this.initialZoom = 40.0,
    this.requiredGPS = true,
    this.myLocationButtonEnabled = true,
    this.layersButtonEnabled = true,
    this.automaticallyAnimateToCurrentLocation = true,
    this.mapStylePath,
    this.appBarColor = Colors.blue,
    this.searchBarBoxDecoration,
    this.hintText,
    this.resultCardConfirmIcon = const Icon(Icons.arrow_forward),
    this.resultCardAlignment = Alignment.bottomCenter,
    this.resultCardDecoration,
    this.resultCardPadding = const EdgeInsets.all(16.0),
    this.countries = const ["IN"],
    this.language = 'en',
    this.desiredAccuracy = LocationAccuracy.bestForNavigation,
  }) : super(key: key);

  final String apiKey;

  final LatLng initialCenter;
  final double initialZoom;
  final List<String> countries;

  final bool requiredGPS;
  final bool myLocationButtonEnabled;
  final bool layersButtonEnabled;
  final bool automaticallyAnimateToCurrentLocation;

  final String? mapStylePath;

  final Color appBarColor;
  final BoxDecoration? searchBarBoxDecoration;
  final String? hintText;
  final Widget resultCardConfirmIcon;
  final Alignment resultCardAlignment;
  final Decoration? resultCardDecoration;
  final EdgeInsets resultCardPadding;

  final String language;

  final LocationAccuracy desiredAccuracy;

  @override
  LocationPickerState createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call
  String sessionToken = const Uuid().v4();

  var mapKey = GlobalKey<MapPickerState>();

  var appBarKey = GlobalKey();

  var searchInputKey = GlobalKey<SearchInputState>();

  bool hasSearchTerm = false;

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    if (context == null) return;

    clearOverlay();

    setState(() => hasSearchTerm = place.length > 0);

    if (place.length < 1) return;

    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    Size size = renderBox.size;

    final RenderBox appBarBox =
        appBarKey.currentContext!.findRenderObject()! as RenderBox;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox.size.height,
        width: size.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    S.of(context).finding_place,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry!);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  Future<void> autoCompleteSearch(String place) async {
    place = place.replaceAll(" ", "+");

    final countries = widget.countries;

    // Currently, you can use components to filter by up to 5 countries. from https://developers.google.com/places/web-service/autocomplete
    String regionParam = countries.isNotEmpty == true
        ? "&components=country:${countries.sublist(0, min(countries.length, 5)).join('|country:')}"
        : "";

    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$place$regionParam&key=${widget.apiKey}&sessiontoken=$sessionToken";

    if (locationResult != null) {
      endpoint += "&location=${locationResult?.latLng.latitude},"
          "${locationResult?.latLng.longitude}";
    }

    try {
      final response = await http.get(
        Uri.parse(endpoint),
      );
      logger.i(endpoint);
      logger.v(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];

        List<RichSuggestion> suggestions = [];

        if (predictions.isEmpty) {
          AutoCompleteItem aci = AutoCompleteItem();
          aci.text = S.of(context).no_result_found;
          aci.offset = 0;
          aci.length = 0;

          suggestions.add(RichSuggestion(aci, () {}));
        } else {
          for (dynamic t in predictions) {
            AutoCompleteItem aci = AutoCompleteItem();

            aci.id = t['place_id'];
            aci.text = t['description'];
            aci.offset = t['matched_substrings'][0]['offset'];
            aci.length = t['matched_substrings'][0]['length'];

            suggestions.add(RichSuggestion(aci, () {
              decodeAndSelectPlace(aci.id);
            }));
          }
        }

        displayAutoCompleteSuggestions(suggestions);
      }
    } catch (error) {
      logger.e(error);
      logger.i(endpoint);
    }
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String placeId) async {
    clearOverlay();

    final endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}"
        "&placeid=$placeId"
        '&language=${widget.language}';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
      );
      logger.i(endpoint);
      logger.v(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
            jsonDecode(response.body)['result']['geometry']['location'];

        LatLng latLng = LatLng(location['lat'], location['lng']);

        moveToLocation(latLng);
      }
    } catch (error) {
      logger.e(error);
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    Size size = renderBox.size;

    final RenderBox appBarBox =
        appBarKey.currentContext!.findRenderObject()! as RenderBox;

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(
          elevation: 1,
          child: Column(
            children: suggestions,
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
//  String getLocationName() {
//    if (locationResult == null) {
//      return "Unnamed location";
//    }
//
//    for (NearbyPlace np in nearbyPlaces) {
//      if (np.latLng == locationResult.latLng) {
//        locationResult.name = np.name;
//        return np.name;
//      }
//    }
//
//    return "${locationResult.name}, ${locationResult.locality}";
//  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) async {
    var endpoint =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "key=${widget.apiKey}&"
        "location=${latLng.latitude},${latLng.longitude}&radius=150"
        "&language=${widget.language}";
    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        nearbyPlaces.clear();
        for (Map<String, dynamic> item
            in jsonDecode(response.body)['results']) {
          NearbyPlace nearbyPlace = NearbyPlace();

          nearbyPlace.name = item['name'];
          nearbyPlace.icon = item['icon'];
          double latitude = item['geometry']['location']['lat'];
          double longitude = item['geometry']['location']['lng'];

          LatLng _latLng = LatLng(latitude, longitude);

          nearbyPlace.latLng = _latLng;

          nearbyPlaces.add(nearbyPlace);
        }
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        hasSearchTerm = false;
      });
    } catch (error) {
      logger.e(error);
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  Future reverseGeocodeLatLng(LatLng latLng) async {
    final endpoint =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}"
                "&key=${widget.apiKey}" +
            "&language=${widget.language}";

    final response = await http.get(
      Uri.parse(endpoint),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);

      String road;

      String placeId = responseJson['results'][0]['place_id'];

      if (responseJson['status'] == 'REQUEST_DENIED') {
        road = 'REQUEST DENIED = please see log for more details';
        logger.e(responseJson['error_message']);
      } else {
        road =
            responseJson['results'][0]['address_components'][0]['short_name'];
      }

//      String locality =
//          responseJson['results'][0]['address_components'][1]['short_name'];

      setState(() {
        locationResult = LocationResult();
        locationResult?.address = road;
        locationResult?.latLng = latLng;
        locationResult?.placeId = placeId;
      });
    }
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    mapKey.currentState?.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 16,
          ),
        ),
      );
    });

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

  @override
  void dispose() {
    clearOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            elevation: 0,
            backgroundColor: widget.appBarColor,
            key: appBarKey,
            title: SearchInput(
              (input) => searchPlace(input),
              key: searchInputKey,
              boxDecoration: widget.searchBarBoxDecoration,
              hintText: widget.hintText,
            ),
          ),
          body: MapPicker(
            widget.apiKey,
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            requiredGPS: widget.requiredGPS,
            myLocationButtonEnabled: widget.myLocationButtonEnabled,
            layersButtonEnabled: widget.layersButtonEnabled,
            automaticallyAnimateToCurrentLocation:
                widget.automaticallyAnimateToCurrentLocation,
            mapStylePath: widget.mapStylePath,
            appBarColor: widget.appBarColor,
            searchBarBoxDecoration: widget.searchBarBoxDecoration,
            hintText: widget.hintText,
            resultCardConfirmIcon: widget.resultCardConfirmIcon,
            resultCardAlignment: widget.resultCardAlignment,
            resultCardDecoration: widget.resultCardDecoration,
            resultCardPadding: widget.resultCardPadding,
            key: mapKey,
            language: widget.language,
            desiredAccuracy: widget.desiredAccuracy,
          ),
        );
      }),
    );
  }
}

/// Returns a [LatLng] object of the location that was picked.
///
/// The [apiKey] argument API key generated from Google Cloud Console.
/// You can get an API key [here](https://cloud.google.com/maps-platform/)
///
/// [initialCenter] The geographical location that the camera is pointing
/// until the current user location is know if you want to change this
/// set [automaticallyAnimateToCurrentLocation] to false.
///
///
Future<LocationResult?> showLocationPicker(
  BuildContext context,
  String apiKey, {
  LatLng initialCenter = const LatLng(45.521563, -122.677433),
  double initialZoom = 16,
  bool requiredGPS = false,
  List<String> countries = const ["IN"],
  bool myLocationButtonEnabled = false,
  bool layersButtonEnabled = false,
  bool automaticallyAnimateToCurrentLocation = true,
  String? mapStylePath,
  Color appBarColor = Colors.transparent,
  BoxDecoration? searchBarBoxDecoration,
  String? hintText,
  Widget resultCardConfirmIcon = const Icon(Icons.arrow_forward),
  Alignment resultCardAlignment = Alignment.bottomCenter,
  EdgeInsets resultCardPadding = const EdgeInsets.all(16.0),
  Decoration? resultCardDecoration,
  String language = 'en',
  LocationAccuracy desiredAccuracy = LocationAccuracy.best,
}) async {
  final results = await Navigator.of(context).push(
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        // print('[LocationPicker] [countries] ${countries.join(', ')}');
        return LocationPicker(
          apiKey,
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          requiredGPS: requiredGPS,
          myLocationButtonEnabled: myLocationButtonEnabled,
          layersButtonEnabled: layersButtonEnabled,
          automaticallyAnimateToCurrentLocation:
              automaticallyAnimateToCurrentLocation,
          mapStylePath: mapStylePath,
          appBarColor: appBarColor,
          hintText: hintText,
          searchBarBoxDecoration: searchBarBoxDecoration,
          resultCardConfirmIcon: resultCardConfirmIcon,
          resultCardAlignment: resultCardAlignment,
          resultCardPadding: resultCardPadding,
          resultCardDecoration: resultCardDecoration,
          countries: countries,
          language: language,
          desiredAccuracy: desiredAccuracy,
        );
      },
    ),
  );

  if (results != null && results.containsKey('location')) {
    return results['location'];
  } else {
    return null;
  }
}
