import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webapi/geocoding.dart";
import 'package:google_maps_webapi/places.dart';
import 'package:http/http.dart';

import 'autocomplete_view.dart';
import 'logger.dart';

class GoogleMapLocationPicker extends StatefulWidget {
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

  /// Top card text field hint text
  final String searchHintText;

  /// Bottom card shape
  final ShapeBorder bottomCardShape;

  /// Bottom card margin
  final EdgeInsetsGeometry bottomCardMargin;

  /// Bottom card icon
  final Widget? nextButton;

  /// Bottom card color
  final Color? bottomCardColor;

  /// On location permission callback
  final bool hasLocationPermission;

  /// detect location button click callback
  final Function()? getLocation;

  /// On Next Page callback
  final Function(GeocodingResult?)? onNext;

  /// When tap on map decode address callback function
  final Function(GeocodingResult?)? onDecodeAddress;

  /// Show more suggestions
  final bool hideMoreOptions;

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

  /// Types for restricting results to a set of place types
  final List<String> types;

  /// Components set results to be restricted to a specific area
  /// components: [Component(Component.country, "us")]
  final List<Component> components;

  /// Bounds for restricting results to a set of bounds
  final bool strictbounds;

  /// Region for restricting results to a set of regions
  /// region: "us"
  final String? region;

  /// List of fields to be returned by the Google Maps Places API.
  /// Refer to the Google Documentation here for a list of valid values: https://developers.google.com/maps/documentation/places/web-service/details
  final List<String> fields;

  /// Hide Suggestions on keyboard hide
  final bool hideSearchBar;

  /// Map type (default: MapType.normal)
  final MapType mapType;

  /// Add your own custom markers
  final Map<String, LatLng>? additionalMarkers;

  /// Safe area parameters (default: true)
  final bool bottom;
  final bool left;
  final bool maintainBottomViewPadding;
  final EdgeInsets minimum;
  final bool right;
  final bool top;

  /// hide location button and map type button (default: false)
  final bool hideLocationButton;
  final bool hideMapTypeButton;

  /// hide bottom card (default: false)
  final bool hideBottomCard;

  final BorderRadiusGeometry borderRadius;

  final Iterable<Widget>? viewTrailing;

  final BorderSide? viewSide;

  final OutlinedBorder? viewShape;

  final Widget? viewLeading;

  final String? viewHintText;

  final Color? viewBackgroundColor;

  final Color? dividerColor;

  final BoxConstraints? constraints;

  final Iterable<Widget>? barTrailing;

  final MaterialStateProperty<TextStyle?>? barTextStyle;

  final MaterialStateProperty<BorderSide?>? barSide;

  final MaterialStateProperty<EdgeInsetsGeometry?>? barPadding;

  final MaterialStateProperty<Color?>? barOverlayColor;

  final Widget? barLeading;

  final MaterialStateProperty<TextStyle?>? barHintStyle;

  final MaterialStateProperty<Color?>? barBackgroundColor;

  final MaterialStateProperty<OutlinedBorder?>? barShape;

  final void Function()? onBarTap;

  final bool isFullScreen;

  final MaterialStateProperty<double?>? barElevation;

  final TextStyle? headerHintStyle;

  final TextStyle? headerTextStyle;

  final Widget Function(BuildContext, List<Prediction>?)? listBuilder;

  final BoxConstraints? viewConstraints;

  final void Function(Prediction?)? onSuggestionSelected;
  final void Function(PlacesDetailsResponse?)? onPlacesDetailsResponse;

  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)?
      suggestionsBuilder;

  final double? viewElevation;

  const GoogleMapLocationPicker({
    Key? key,
    this.onPlacesDetailsResponse,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.viewTrailing,
    this.viewSide,
    this.viewShape,
    this.viewLeading,
    this.viewHintText,
    this.viewBackgroundColor,
    this.dividerColor,
    this.constraints,
    this.barTrailing,
    this.barTextStyle,
    this.barSide,
    this.barPadding,
    this.barOverlayColor,
    this.barLeading,
    this.barHintStyle,
    this.barBackgroundColor,
    this.barShape,
    this.onBarTap,
    this.isFullScreen = false,
    this.barElevation,
    this.headerHintStyle,
    this.headerTextStyle,
    this.listBuilder,
    this.viewConstraints,
    this.onSuggestionSelected,
    this.suggestionsBuilder,
    this.viewElevation,
    this.desiredAccuracy = LocationAccuracy.high,
    required this.apiKey,
    this.geoCodingBaseUrl,
    this.geoCodingHttpClient,
    this.geoCodingApiHeaders,
    this.language,
    this.locationType = const [],
    this.resultType = const [],
    this.minMaxZoomPreference = const MinMaxZoomPreference(0, 16),
    this.padding = const EdgeInsets.all(0),
    this.compassEnabled = true,
    this.liteModeEnabled = false,
    this.searchHintText = "Start typing to search",
    this.bottomCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.bottomCardMargin = const EdgeInsets.fromLTRB(8, 8, 8, 16),
    this.nextButton = const Icon(Icons.send),
    this.bottomCardColor,
    this.hasLocationPermission = true,
    this.getLocation,
    this.onNext,
    this.currentLatLng = const LatLng(28.8993468, 76.6250249),
    this.hideMoreOptions = false,
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
    this.hideSearchBar = false,
    this.mapType = MapType.normal,
    this.additionalMarkers,
    this.bottom = true,
    this.left = true,
    this.maintainBottomViewPadding = false,
    this.minimum = EdgeInsets.zero,
    this.right = true,
    this.top = true,
    this.hideLocationButton = false,
    this.hideMapTypeButton = false,
    this.hideBottomCard = false,
    this.onDecodeAddress,
  }) : super(key: key);

  @override
  State<GoogleMapLocationPicker> createState() =>
      _GoogleMapLocationPickerState();
}

class _GoogleMapLocationPickerState extends State<GoogleMapLocationPicker> {
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

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    _mapType = widget.mapType;
    if (widget.currentLatLng != null) {
      _decodeAddress(
        Location(
          lat: _initialPosition.latitude,
          lng: _initialPosition.longitude,
        ),
      );
    }
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
    markers.add(
      Marker(
        markerId: const MarkerId("one"),
        position: _initialPosition,
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Material(
        child: SafeArea(
          bottom: widget.bottom,
          left: widget.left,
          maintainBottomViewPadding: widget.maintainBottomViewPadding,
          minimum: widget.minimum,
          right: widget.right,
          top: widget.top,
          child: Stack(
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
                    CameraUpdate.newCameraPosition(cameraPosition()),
                  );
                  _decodeAddress(
                    Location(
                      lat: position.latitude,
                      lng: position.longitude,
                    ),
                  );
                  setState(() {});
                },
                onMapCreated: (GoogleMapController controller) =>
                    _controller.complete(controller),
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
                  if (!widget.hideSearchBar)
                    Container(
                      margin: widget.bottomCardMargin,
                      child: PlacesAutocomplete(
                        apiKey: widget.apiKey,
                        borderRadius: widget.borderRadius,
                        offset: widget.offset,
                        radius: widget.radius,
                        components: widget.components,
                        fields: widget.fields,
                        language: widget.language,
                        location: widget.location,
                        origin: widget.origin,
                        placesApiHeaders: widget.placesApiHeaders,
                        placesBaseUrl: widget.placesBaseUrl,
                        placesHttpClient: widget.placesHttpClient,
                        region: widget.region,
                        searchHintText: widget.searchHintText,
                        sessionToken: widget.sessionToken,
                        strictbounds: widget.strictbounds,
                        types: widget.types,
                        viewTrailing: widget.viewTrailing,
                        viewSide: widget.viewSide,
                        viewShape: widget.viewShape,
                        viewLeading: widget.viewLeading,
                        viewHintText: widget.viewHintText,
                        viewBackgroundColor: widget.viewBackgroundColor,
                        dividerColor: widget.dividerColor,
                        constraints: widget.constraints,
                        barTrailing: widget.barTrailing,
                        barTextStyle: widget.barTextStyle,
                        barSide: widget.barSide,
                        barPadding: widget.barPadding,
                        barOverlayColor: widget.barOverlayColor,
                        barLeading: widget.barLeading,
                        barHintStyle: widget.barHintStyle,
                        barBackgroundColor: widget.barBackgroundColor,
                        onTap: widget.onBarTap,
                        barShape: widget.barShape,
                        isFullScreen: widget.isFullScreen,
                        barElevation: widget.barElevation,
                        headerHintStyle: widget.headerHintStyle,
                        headerTextStyle: widget.headerTextStyle,
                        listBuilder: widget.listBuilder,
                        onSuggestionSelected: widget.onSuggestionSelected,
                        suggestionsBuilder: widget.suggestionsBuilder,
                        viewConstraints: widget.viewConstraints,
                        viewElevation: widget.viewElevation,
                        onPlacesDetailsResponse: (placesDetails) async {
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
                          _address =
                              placesDetails.result.formattedAddress ?? "";
                          widget.onPlacesDetailsResponse?.call(placesDetails);
                          _geocodingResult = GeocodingResult(
                            geometry: placesDetails.result.geometry!,
                            placeId: placesDetails.result.placeId,
                            addressComponents:
                                placesDetails.result.addressComponents,
                            formattedAddress:
                                placesDetails.result.formattedAddress,
                            types: placesDetails.result.types,
                          );

                          // updating the suggestion box modal data
                          _decodeAddress(
                            Location(
                                lat: _initialPosition.latitude,
                                lng: _initialPosition.longitude),
                          );

                          setState(() {});
                        },
                      ),
                    ),
                  Spacer(),
                  if (!widget.hideMapTypeButton)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton.small(
                        tooltip: 'Map Type',
                        heroTag: 'mapType',
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
                        onPressed: null,
                      ),
                    ),
                  if (!widget.hideLocationButton)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton.small(
                        tooltip: 'My Location',
                        heroTag: 'myLocation',
                        onPressed: () async {
                          // call parent method
                          if (widget.getLocation != null) {
                            widget.getLocation!.call();
                          }

                          if (widget.hasLocationPermission) {
                            await Geolocator.requestPermission();
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: widget.desiredAccuracy,
                            );
                            LatLng latLng =
                                LatLng(position.latitude, position.longitude);
                            _initialPosition = latLng;
                            final controller = await _controller.future;
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                cameraPosition(),
                              ),
                            );
                            _decodeAddress(
                              Location(
                                lat: position.latitude,
                                lng: position.longitude,
                              ),
                            );
                            setState(() {});
                          }
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  if (!widget.hideBottomCard)
                    Card(
                      margin: widget.bottomCardMargin,
                      shape: widget.bottomCardShape,
                      color: widget.bottomCardColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(_address),
                            onTap: () => widget.onNext?.call(_geocodingResult),
                            trailing: widget.nextButton,
                          ),
                          if (!widget.hideMoreOptions &&
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
                                      children:
                                          _geocodingResultList.map((element) {
                                        return ListTile(
                                          title: Text(
                                              element.formattedAddress ?? ""),
                                          onTap: () {
                                            _address =
                                                element.formattedAddress ?? "";
                                            _geocodingResult = element;
                                            setState(() {});
                                            Navigator.pop(context, element);
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
        ),
      ),
    );
  }

  /// Decode address from latitude & longitude
  void _decodeAddress(Location location) async {
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
      widget.onDecodeAddress?.call(_geocodingResult);
      if (response.results.length > 1) {
        _geocodingResultList = response.results;
      }
      setState(() {});
    } catch (e) {
      logger.e(e);
    }
  }
}
