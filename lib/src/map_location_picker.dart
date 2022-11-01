import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import "package:google_maps_webapi/geocoding.dart";
import 'package:google_maps_webapi/places.dart';
import 'logger.dart';
import 'autocomplete_view.dart';

class MapLocationPicker extends StatefulWidget {
  /// Padding around the map
  final EdgeInsets padding;

  /// Compass for the map (default: true)
  final bool compassEnabled;

  /// Lite mode for the map (default: false)
  final bool liteModeEnabled;

  /// API key for the map & places
  final String apiKey;

  /// GPS accuracy for the map
  final LocationAccuracy desiredAccuracy;

  /// GeoCoding base url
  final String? geoCodingBaseUrl;

  /// GeoCoding http client
  final Client? geoCodingHttpClient;

  /// GeoCoding api headers
  final Map<String, String>? geoCodingApiHeaders;

  /// GeoCoding location type
  final List<String> locationType;

  /// GeoCoding result type
  final List<String> resultType;

  /// Map minimum zoom level & maximum zoom level
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Top card margin
  final EdgeInsetsGeometry topCardMargin;

  /// Top card color
  final Color? topCardColor;

  /// Top card shape
  final ShapeBorder topCardShape;

  /// Top card text field border radius
  final BorderRadius? borderRadius;

  /// Top card text field hint text
  final String searchHintText;

  /// Bottom card shape
  final ShapeBorder bottomCardShape;

  /// Bottom card margin
  final EdgeInsetsGeometry bottomCardMargin;

  /// Bottom card icon
  final Icon bottomCardIcon;

  /// Bottom card tooltip
  final String bottomCardTooltip;

  /// Bottom card color
  final Color? bottomCardColor;

  /// On Suggestion Selected callback
  final Function(PlacesDetailsResponse?)? onSuggestionSelected;

  /// On Next Page callback
  final Function(GeocodingResult?) onNext;

  /// Show back button (default: true)
  final bool showBackButton;

  /// Popup route on next press (default: false)
  final bool canPopOnNextButtonTaped;

  /// Back button replacement when [showBackButton] is false and [backButton] is not null
  final Widget? backButton;

  /// Show more suggestions
  final bool showMoreOptions;

  /// Dialog title
  final String dialogTitle;

  /// httpClient is used to make network requests.
  final Client? placesHttpClient;

  /// apiHeader is used to add headers to the request.
  final Map<String, String>? placesApiHeaders;

  /// baseUrl is used to build the url for the request.
  final String? placesBaseUrl;

  /// Session token for Google Places API
  final String? sessionToken;

  /// Offset for pagination of results
  /// offset: int,
  final num? offset;

  /// Origin location for calculating distance from results
  /// origin: Location(lat: -33.852, lng: 151.211),
  final Location? origin;

  /// currentLatLng init location for camera position
  /// currentLatLng: Location(lat: -33.852, lng: 151.211),
  final LatLng? currentLatLng;

  /// Location bounds for restricting results to a radius around a location
  /// location: Location(lat: -33.867, lng: 151.195)
  final Location? location;

  /// Radius for restricting results to a radius around a location
  /// radius: Radius in meters
  final num? radius;

  /// Language code for Places API results
  /// language: 'en',
  final String? language;

  final TextStyle? buttonTextStyle;

  /// Types for restricting results to a set of place types
  final List<String> types;

  /// Components set results to be restricted to a specific area
  /// components: [Component(Component.country, "us")]
  final List<Component> components;

  /// Bounds for restricting results to a set of bounds
  final bool strictbounds;
  final bool showMapSwitcher;

  /// Region for restricting results to a set of regions
  /// region: "us"
  final String? region;

  /// fields
  final List<String> fields;

  /// Hide Suggestions on keyboard hide
  final bool hideSuggestionsOnKeyboardHide;

  /// Map type (default: MapType.normal)
  final MapType mapType;

  /// Search text field controller
  final TextEditingController? searchController;

  /// Add your own custom markers
  final Map<String, LatLng>? additionalMarkers;

  const MapLocationPicker({
    Key? key,
    this.desiredAccuracy = LocationAccuracy.high,
    required this.apiKey,
    this.geoCodingBaseUrl,
    this.geoCodingHttpClient,
    this.geoCodingApiHeaders,
    this.language,
    this.showMapSwitcher = true,
    this.buttonTextStyle,
    this.locationType = const [],
    this.resultType = const [],
    this.minMaxZoomPreference = const MinMaxZoomPreference(10, 20),
    this.padding = const EdgeInsets.all(0),
    this.compassEnabled = true,
    this.liteModeEnabled = false,
    this.topCardMargin = const EdgeInsets.all(8),
    this.topCardColor,
    this.topCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.searchHintText = "Search for your address",
    this.bottomCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.bottomCardMargin = const EdgeInsets.fromLTRB(8, 8, 8, 16),
    this.bottomCardIcon = const Icon(Icons.send),
    this.bottomCardTooltip = "Continue with this location",
    this.bottomCardColor,
    this.onSuggestionSelected,
    required this.onNext,
    this.currentLatLng = const LatLng(28.8993468, 76.6250249),
    this.showBackButton = true,
    this.canPopOnNextButtonTaped = false,
    this.backButton,
    this.showMoreOptions = true,
    this.dialogTitle = 'You can also use the following options',
    this.placesHttpClient,
    this.placesApiHeaders,
    this.placesBaseUrl,
    this.sessionToken,
    this.offset,
    this.origin,
    this.location,
    this.radius,
    this.region,
    this.fields = const [],
    this.types = const [],
    this.components = const [],
    this.strictbounds = false,
    this.hideSuggestionsOnKeyboardHide = false,
    this.mapType = MapType.normal,
    this.searchController,
    this.additionalMarkers,
  }) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  /// Map controller for movement & zoom
  final Completer<GoogleMapController> _controller = Completer();

  /// initial latitude & longitude
  late LatLng _initialPosition = const LatLng(28.8993468, 76.6250249);

  /// initial address text
  late String _address = "Tap on map to get address";

  /// Map type (default: MapType.normal)
  late MapType _mapType = MapType.normal;

  /// initial zoom level
  late double _zoom = 18.0;

  /// GeoCoding result for further use
  GeocodingResult? _geocodingResult;

  /// GeoCoding results list for further use
  late List<GeocodingResult> _geocodingResultList = [];

  /// Camera position moved to location
  CameraPosition cameraPosition() {
    return CameraPosition(
      target: _initialPosition,
      zoom: _zoom,
    );
  }

  /// Search text field controller
  late TextEditingController _searchController = TextEditingController();

  /// Decode address from latitude & longitude
  Future<void> _decodeAddress(Location location) async {
    try {
      final geocoding = GoogleMapsGeocoding(
        apiKey: widget.apiKey,
        baseUrl: widget.geoCodingBaseUrl,
        apiHeaders: widget.geoCodingApiHeaders,
        httpClient: widget.geoCodingHttpClient,
      );
      final response = await geocoding.searchByLocation(
        location,
        language: widget.language,
        locationType: widget.locationType,
        resultType: widget.resultType,
      );

      /// When get any error from the API, show the error in the console.
      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        logger.e(response.errorMessage);
        _address = response.status;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ??
                  "Address not found, something went wrong!"),
            ),
          );
        }
        return;
      }
      _address = response.results.first.formattedAddress ?? "";
      _geocodingResult = response.results.first;
      if (response.results.length > 1) {
        _geocodingResultList = response.results;
      }
      setState(() {});
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    _mapType = widget.mapType;
    _searchController = widget.searchController ?? _searchController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final additionalMarkers = widget.additionalMarkers?.entries
            .map(
              (e) => Marker(
                markerId: MarkerId(e.key),
                position: e.value,
              ),
            )
            .toList() ??
        [];

    final markers = Set<Marker>.from(additionalMarkers);

    markers.add(Marker(
      markerId: const MarkerId("one"),
      position: _initialPosition,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: _searchController.text.isEmpty,
        toolbarHeight: 90,
        title: Container(
          width: double.infinity,
          height: 60,
          color: Colors.white,
          child: Center(
            child: PlacesAutocomplete(
              apiKey: widget.apiKey,
              mounted: mounted,
              searchController: _searchController,
              borderRadius: widget.borderRadius,
              offset: widget.offset,
              radius: widget.radius,
              backButton: widget.backButton,
              components: widget.components,
              fields: widget.fields,
              hideSuggestionsOnKeyboardHide:
                  widget.hideSuggestionsOnKeyboardHide,
              language: widget.language,
              location: widget.location,
              origin: widget.origin,
              placesApiHeaders: widget.placesApiHeaders,
              placesBaseUrl: widget.placesBaseUrl,
              placesHttpClient: widget.placesHttpClient,
              region: widget.region,
              searchHintText: widget.searchHintText,
              sessionToken: widget.sessionToken,
              showBackButton: widget.showBackButton,
              strictbounds: widget.strictbounds,
              topCardColor: widget.topCardColor,
              topCardMargin: widget.topCardMargin,
              topCardShape: widget.topCardShape,
              types: widget.types,
              onChange: (s) {
                setState(() {});
              },
              onGetDetailsByPlaceId: (placesDetails) async {
                if (placesDetails == null) {
                  logger.e("placesDetails is null");
                  return;
                }
                _initialPosition = LatLng(
                  placesDetails.result.geometry?.location.lat ?? 0,
                  placesDetails.result.geometry?.location.lng ?? 0,
                );
                final controller = await _controller.future;
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition()));
                await _decodeAddress(Location(
                    lat: placesDetails.result.geometry?.location.lat ?? 0,
                    lng: placesDetails.result.geometry?.location.lng ?? 0));
                _address = placesDetails.result.formattedAddress ?? "";
                widget.onSuggestionSelected?.call(placesDetails);
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Google map view
          GoogleMap(
            minMaxZoomPreference: widget.minMaxZoomPreference,
            onCameraMove: (CameraPosition position) {
              /// set zoom level
              _zoom = position.zoom;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: _zoom,
            ),
            onTap: (LatLng position) async {
              _initialPosition = position;
              final controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition()));
              await _decodeAddress(
                  Location(lat: position.latitude, lng: position.longitude));
              setState(() {});
            },
            onMapCreated: (GoogleMapController controller) async {
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                _controller.complete(controller);
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('one'),
                position: _initialPosition,
              ),
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            padding: widget.padding,
            compassEnabled: widget.compassEnabled,
            liteModeEnabled: widget.liteModeEnabled,
            mapType: widget.mapType,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // PlacesAutocomplete(
              //   apiKey: widget.apiKey,
              //   mounted: mounted,
              //   searchController: _searchController,
              //   borderRadius: widget.borderRadius,
              //   offset: widget.offset,
              //   radius: widget.radius,
              //   backButton: widget.backButton,
              //   components: widget.components,
              //   fields: widget.fields,
              //   hideSuggestionsOnKeyboardHide:
              //       widget.hideSuggestionsOnKeyboardHide,
              //   language: widget.language,
              //   location: widget.location,
              //   origin: widget.origin,
              //   placesApiHeaders: widget.placesApiHeaders,
              //   placesBaseUrl: widget.placesBaseUrl,
              //   placesHttpClient: widget.placesHttpClient,
              //   region: widget.region,
              //   searchHintText: widget.searchHintText,
              //   sessionToken: widget.sessionToken,
              //   showBackButton: widget.showBackButton,
              //   strictbounds: widget.strictbounds,
              //   topCardColor: widget.topCardColor,
              //   topCardMargin: widget.topCardMargin,
              //   topCardShape: widget.topCardShape,
              //   types: widget.types,
              //   onGetDetailsByPlaceId: (placesDetails) async {
              //     if (placesDetails == null) {
              //       logger.e("placesDetails is null");
              //       return;
              //     }
              //     _initialPosition = LatLng(
              //       placesDetails.result.geometry?.location.lat ?? 0,
              //       placesDetails.result.geometry?.location.lng ?? 0,
              //     );
              //     final controller = await _controller.future;
              //     controller.animateCamera(
              //         CameraUpdate.newCameraPosition(cameraPosition()));
              //     _address = placesDetails.result.formattedAddress ?? "";
              //     widget.onSuggestionSelected?.call(placesDetails);
              //     setState(() {});
              //   },
              // ),

              const Spacer(),
              if (widget.showMapSwitcher)
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(360),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(4.5),
                      child: PopupMenuButton(
                        tooltip: 'Map Type',
                        initialValue: _mapType,
                        icon: Icon(
                          Icons.layers,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onSelected: (MapType mapType) {
                          setState(() {
                            _mapType = mapType;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: MapType.normal,
                            child: Text('Normal'),
                          ),
                          PopupMenuItem(
                            value: MapType.hybrid,
                            child: Text('Hybrid'),
                          ),
                          PopupMenuItem(
                            value: MapType.satellite,
                            child: Text('Satellite'),
                          ),
                          PopupMenuItem(
                            value: MapType.terrain,
                            child: Text('Terrain'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  tooltip: 'My Location',
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () async {
                    await Geolocator.requestPermission();
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: widget.desiredAccuracy,
                    );
                    LatLng latLng =
                        LatLng(position.latitude, position.longitude);
                    _initialPosition = latLng;
                    (await _controller.future).animateCamera(
                        CameraUpdate.newCameraPosition(cameraPosition()));
                    _decodeAddress(Location(
                        lat: position.latitude, lng: position.longitude));
                    setState(() {});
                  },
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Card(
                margin: widget.bottomCardMargin,
                shape: widget.bottomCardShape,
                color: widget.bottomCardColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 16, right: 16),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Location",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey.shade500),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: Colors.grey.shade500),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.39,
                                    child: Text(
                                      _address,
                                      maxLines: 4,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  widget.onNext.call(_geocodingResult);
                                  if (widget.canPopOnNextButtonTaped) {
                                    Future.delayed(Duration.zero, () {
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    primary: Theme.of(context).primaryColor,
                                    textStyle: widget.buttonTextStyle ??
                                        const TextStyle(fontSize: 16)),
                                child: const Text(
                                  'Confirm Location',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.showMoreOptions &&
                        _geocodingResultList.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(widget.dialogTitle),
                              scrollable: true,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _geocodingResultList.map((element) {
                                  return ListTile(
                                    title: Text(element.formattedAddress ?? ""),
                                    onTap: () {
                                      _address = element.formattedAddress ?? "";
                                      _geocodingResult = element;
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Chip(
                          label: Text(
                            "Tap to show ${(_geocodingResultList.length - 1)} more result options",
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
