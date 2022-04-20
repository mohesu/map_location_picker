import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:map_location_picker/generated/l10n.dart';
import 'package:map_location_picker/src/providers/location_provider.dart';
import 'package:map_location_picker/src/utils/loading_builder.dart';
import 'package:map_location_picker/src/utils/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../logger.dart';
import 'model/location_result.dart';

class MapPicker extends StatefulWidget {
  const MapPicker(
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
    this.language = 'en',
    this.desiredAccuracy = LocationAccuracy.bestForNavigation,
  }) : super(key: key);

  final String apiKey;

  final LatLng initialCenter;
  final double initialZoom;

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
  MapPickerState createState() => MapPickerState();
}

class MapPickerState extends State<MapPicker> {
  Completer<GoogleMapController> mapController = Completer();

  MapType _currentMapType = MapType.normal;

  String? _mapStyle;

  LatLng? _lastMapPosition;

  Position? _currentPosition;

  String? _address;
  String? _placeId;
  String? _streetNumber;
  String? _route;
  String? _locality;
  String? _administrativeAreaLevel2;
  String? _administrativeAreaLevel1;
  String? _country;
  String? _postalCode;

  void _onToggleMapTypePressed() {
    final MapType nextType =
        MapType.values[(_currentMapType.index + 1) % MapType.values.length];

    setState(() => _currentMapType = nextType);
  }

  // this also checks for location permission.
  Future<void> _initCurrentLocation() async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: widget.desiredAccuracy);
      d("position = $currentPosition");

      setState(() => _currentPosition = currentPosition);
    } catch (e) {
      currentPosition = null;
      d("_initCurrentLocation#e = $e");
    }

    if (!mounted) return;

    setState(() => _currentPosition = currentPosition);

    if (currentPosition != null) {
      moveToCurrentLocation(
          LatLng(currentPosition.latitude, currentPosition.longitude));
    }
  }

  Future moveToCurrentLocation(LatLng currentLocation) async {
    d('MapPickerState.moveToCurrentLocation "currentLocation = [$currentLocation]"');
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: 16),
    ));
  }

  @override
  void initState() {
    super.initState();
    if (widget.automaticallyAnimateToCurrentLocation && !widget.requiredGPS) {
      _initCurrentLocation();
    }

    if (widget.mapStylePath != null) {
      rootBundle.loadString(widget.mapStylePath!).then((string) {
        _mapStyle = string;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requiredGPS) {
      _checkGeolocationPermission();
      if (_currentPosition == null) _initCurrentLocation();
    }

    if (_currentPosition != null && dialogOpen != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (_currentPosition == null &&
              widget.automaticallyAnimateToCurrentLocation &&
              widget.requiredGPS) {
            return const Center(child: CircularProgressIndicator());
          }

          return buildMap();
        },
      ),
    );
  }

  Widget buildMap() {
    return Center(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: widget.initialCenter,
              zoom: widget.initialZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
              //Implementation of mapStyle
              if (widget.mapStylePath != null) {
                controller.setMapStyle(_mapStyle);
              }

              _lastMapPosition = widget.initialCenter;
              LocationProvider.of(context, listen: false)
                  .setLastIdleLocation(_lastMapPosition!);
            },
            onCameraMove: (CameraPosition position) {
              _lastMapPosition = position.target;
            },
            onCameraIdle: () async {
              logger.v("onCameraIdle#_lastMapPosition = $_lastMapPosition");
              LocationProvider.of(context, listen: false)
                  .setLastIdleLocation(_lastMapPosition!);
            },
            onCameraMoveStarted: () {
              logger.v(
                  "onCameraMoveStarted#_lastMapPosition = $_lastMapPosition");
            },
//            onTap: (latLng) {
//              clearOverlay();
//            },
            mapType: _currentMapType,
            myLocationEnabled: true,
          ),
          _MapFabs(
            myLocationButtonEnabled: widget.myLocationButtonEnabled,
            layersButtonEnabled: widget.layersButtonEnabled,
            onToggleMapTypePressed: _onToggleMapTypePressed,
            onMyLocationPressed: _initCurrentLocation,
          ),
          pin(),
          locationCard(),
        ],
      ),
    );
  }

  Widget locationCard() {
    return Align(
      alignment: widget.resultCardAlignment,
      child: Padding(
        padding: widget.resultCardPadding,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 20,
                    child: FutureLoadingBuilder<Map<String, String>>(
                      future: getAddress(locationProvider.lastIdleLocation),
                      mutable: true,
                      loadingIndicator: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          CircularProgressIndicator(),
                        ],
                      ),
                      builder: (context, data) {
                        _address = data["address"];
                        _placeId = data["placeId"];
                        _streetNumber = data["streetNumber"];
                        _route = data["route"];
                        _locality = data["locality"];
                        _administrativeAreaLevel2 =
                            data["administrativeAreaLevel2"];
                        _administrativeAreaLevel1 =
                            data["administrativeAreaLevel1"];
                        _country = data["country"];
                        _postalCode = data["postalCode"];
                        return Text(
                          _address ?? S.of(context).unnamedPlace,
                          style: const TextStyle(fontSize: 18),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  FloatingActionButton.small(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'location': LocationResult(
                          latLng: locationProvider.lastIdleLocation,
                          address: _address ?? "",
                          placeId: _placeId ?? "",
                          streetNumber: _streetNumber ?? "",
                          route: _route ?? "",
                          locality: _locality ?? "",
                          administrativeAreaLevel2:
                              _administrativeAreaLevel2 ?? "",
                          administrativeAreaLevel1:
                              _administrativeAreaLevel1 ?? "",
                          country: _country ?? "",
                          postalCode: _postalCode ?? "",
                        )
                      });
                    },
                    child: widget.resultCardConfirmIcon,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<Map<String, String>> getAddress(LatLng location) async {
    try {
      final endpoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}'
          '&key=${widget.apiKey}&language=${widget.language}';

      final response = await http.get(Uri.parse(endpoint));
      logger.i(endpoint);
      logger.v(response.body);
      final json = jsonDecode(response.body);

      List<dynamic> addressComponents =
          json['results'][0]['address_components'];

      String? streetNumber;
      String? route;
      String? locality;
      String? administrativeAreaLevel2;
      String? administrativeAreaLevel1;
      String? country;
      String? postalCode;
      if (addressComponents.isNotEmpty) {
        streetNumber = addressComponents.firstWhereOrNull(
            (entry) => entry['types'].contains('street_number'))?['long_name'];
        route = addressComponents.firstWhereOrNull(
            (entry) => entry['types'].contains('route'))?['long_name'];
        locality = addressComponents.firstWhereOrNull(
            (entry) => entry['types'].contains('locality'))?['long_name'];
        administrativeAreaLevel2 = addressComponents.firstWhereOrNull((entry) =>
            entry['types']
                .contains('administrative_area_level_2'))?['long_name'];
        administrativeAreaLevel1 = addressComponents.firstWhereOrNull((entry) =>
            entry['types']
                .contains('administrative_area_level_1'))?['long_name'];
        country = addressComponents.firstWhereOrNull(
            (entry) => entry['types'].contains('country'))?['long_name'];
        postalCode = addressComponents.firstWhereOrNull(
            (entry) => entry['types'].contains('postal_code'))?['long_name'];
      }

      return {
        "placeId": json['results'][0]['place_id'],
        "address": json['results'][0]['formatted_address'],
        "streetNumber": streetNumber ?? "",
        "route": route ?? "",
        "locality": locality ?? "",
        "administrativeAreaLevel2": administrativeAreaLevel2 ?? "",
        "administrativeAreaLevel1": administrativeAreaLevel1 ?? "",
        "country": country ?? "",
        "postalCode": postalCode ?? "",
      };
    } catch (e) {
      logger.e(e);
    }

    return {"placeId": "place id not found", "address": "address not found"};
  }

  Widget pin() {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.place,
              size: 50,
              color: Colors.red,
            ),
            Container(
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black38,
                  ),
                ],
                shape: CircleBorder(
                  side: BorderSide(
                    width: 4,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  Future<dynamic>? dialogOpen;
  Future _checkGeolocationPermission() async {
    final geolocationStatus = await Geolocator.checkPermission();
    d("geolocationStatus = $geolocationStatus");
    await Geolocator.requestPermission();
    if (geolocationStatus == LocationPermission.denied && dialogOpen == null) {
      dialogOpen = _showDeniedDialog();
    } else if (geolocationStatus == LocationPermission.deniedForever &&
        dialogOpen == null) {
      dialogOpen = _showDeniedForeverDialog();
    } else if (geolocationStatus == LocationPermission.whileInUse ||
        geolocationStatus == LocationPermission.always) {
      d('GeolocationStatus.granted');
      if (dialogOpen != null) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = null;
      }
    }
  }

  Future _showDeniedDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            return true;
          },
          child: AlertDialog(
            title: Text(S.of(context).access_to_location_denied),
            content: Text(S.of(context).allow_access_to_the_location_services),
            actions: <Widget>[
              ElevatedButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _initCurrentLocation();
                  dialogOpen = null;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future _showDeniedForeverDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            return true;
          },
          child: AlertDialog(
            title: Text(S.of(context).access_to_location_permanently_denied),
            content: Text(S
                .of(context)
                .allow_access_to_the_location_services_from_settings),
            actions: <Widget>[
              ElevatedButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Geolocator.openAppSettings();
                  dialogOpen = null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapFabs extends StatelessWidget {
  const _MapFabs({
    Key? key,
    required this.myLocationButtonEnabled,
    required this.layersButtonEnabled,
    required this.onToggleMapTypePressed,
    required this.onMyLocationPressed,
  }) : super(key: key);

  final bool myLocationButtonEnabled;
  final bool layersButtonEnabled;

  final VoidCallback onToggleMapTypePressed;
  final VoidCallback onMyLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: kToolbarHeight + 50, right: 8),
      child: Column(
        children: <Widget>[
          if (layersButtonEnabled)
            FloatingActionButton(
              onPressed: onToggleMapTypePressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              mini: true,
              child: const Icon(Icons.layers),
              heroTag: "layers",
            ),
          if (myLocationButtonEnabled)
            FloatingActionButton(
              onPressed: onMyLocationPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              mini: true,
              child: const Icon(Icons.my_location),
              heroTag: "myLocation",
            ),
        ],
      ),
    );
  }
}
