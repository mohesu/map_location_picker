import 'package:flutter/material.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:http/http.dart';

import '../map_location_picker.dart';
import 'logger.dart';

class PlacesAutocomplete extends StatefulWidget {
  /// API key for the map & places
  final String apiKey;

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

  /// Show back button (default: true)
  final bool showBackButton;

  /// Back button replacement when [showBackButton] is false and [backButton] is not null
  final Widget? backButton;

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

  /// fields
  final List<String> fields;

  /// Hide Suggestions on keyboard hide
  final bool hideSuggestionsOnKeyboardHide;

  /// On get details callback
  final void Function(PlacesDetailsResponse?)? onGetDetailsByPlaceId;

  /// On suggestion selected callback
  final void Function(Prediction)? onSuggestionSelected;

  /// Search text field controller
  final TextEditingController searchController;

  /// Is widget mounted
  final bool mounted;

  /// Can show clear button on search text field
  final bool showClearButton;
  final Function(Prediction?)? onChange;

  /// suffix icon for search text field. You can use [showClearButton] to show clear button or replace with suffix icon
  final Widget? suffixIcon;

  const PlacesAutocomplete({
    Key? key,
    required this.apiKey,
    this.onChange,
    this.language,
    this.topCardMargin = const EdgeInsets.all(8),
    this.topCardColor,
    this.topCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.searchHintText = "Search",
    this.showBackButton = true,
    this.backButton,
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
    required this.searchController,
    required this.mounted,
    this.onGetDetailsByPlaceId,
    this.onSuggestionSelected,
    this.showClearButton = true,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<PlacesAutocomplete> createState() => _PlacesAutocompleteState();
}

class _PlacesAutocompleteState extends State<PlacesAutocomplete> {
  /// Get address details from place id
  void _getDetailsByPlaceId(String placeId, BuildContext context) async {
    try {
      final GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: widget.apiKey,
        httpClient: widget.placesHttpClient,
        apiHeaders: widget.placesApiHeaders,
        baseUrl: widget.placesBaseUrl,
      );
      final PlacesDetailsResponse response = await places.getDetailsByPlaceId(
        placeId,
        region: widget.region,
        sessionToken: widget.sessionToken,
        language: widget.language,
        fields: widget.fields,
      );

      /// When get any error from the API, show the error in the console.
      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        logger.e(response.errorMessage);
        if (widget.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ??
                  "Address not found, something went wrong!"),
            ),
          );
        }
        return;
      }
      widget.onGetDetailsByPlaceId?.call(response);
    } catch (e) {
      logger.e(e);
    }
  }

  AutoCompleteState autoCompleteState() {
    return AutoCompleteState(
      apiHeaders: widget.placesApiHeaders,
      baseUrl: widget.placesBaseUrl,
      httpClient: widget.placesHttpClient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTypeAhead<Prediction>(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFF6F7F9),
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: Color(0xFFF6F7F9),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(15.0),
        ),
        hintText: widget.searchHintText,
        filled: true,
        suffixIcon:
            widget.showClearButton && widget.searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.searchController.clear(),
                  )
                : widget.suffixIcon,
      ),
      name: 'Search',
      onChanged: (s) {},
      controller: widget.searchController,
      selectionToTextTransformer: (result) {
        return result.description ?? "";
      },
      itemBuilder: (context, continent) {
        return ListTile(
          title: Text(continent.description ?? ""),
        );
      },
      suggestionsCallback: (query) async {
        List<Prediction> predictions = await autoCompleteState().search(
          query,
          widget.apiKey,
          language: widget.language,
          sessionToken: widget.sessionToken,
          region: widget.region,
          components: widget.components,
          location: widget.location,
          offset: widget.offset,
          origin: widget.origin,
          radius: widget.radius,
          strictbounds: widget.strictbounds,
          types: widget.types,
        );
        return predictions;
      },
      onSuggestionSelected: (value) async {
        widget.searchController.selection = TextSelection.collapsed(
            offset: widget.searchController.text.length);
        _getDetailsByPlaceId(value.placeId ?? "", context);
        widget.onSuggestionSelected?.call(value);
      },
      hideSuggestionsOnKeyboardHide: widget.hideSuggestionsOnKeyboardHide,
    );
    // return SafeArea(
    //   child: Card(
    //     margin: widget.topCardMargin,
    //     shape: widget.topCardShape,
    //     color: widget.topCardColor,
    //     child: ListTile(
    //       minVerticalPadding: 0,
    //       contentPadding: const EdgeInsets.only(right: 4, left: 4),
    //       leading:
    //           widget.showBackButton ? const BackButton() : widget.backButton,
    //       title: Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
    //         child: FormBuilderTypeAhead<Prediction>(
    //           decoration: InputDecoration(
    //             hintText: widget.searchHintText,
    //             border: InputBorder.none,
    //             filled: true,
    //             suffixIcon: widget.showClearButton
    //                 ? IconButton(
    //                     icon: const Icon(Icons.close),
    //                     onPressed: () => widget.searchController.clear(),
    //                   )
    //                 : widget.suffixIcon,
    //           ),
    //           name: 'Search',
    //           controller: widget.searchController,
    //           selectionToTextTransformer: (result) {
    //             return result.description ?? "";
    //           },
    //           itemBuilder: (context, continent) {
    //             return ListTile(
    //               title: Text(continent.description ?? ""),
    //             );
    //           },
    //           suggestionsCallback: (query) async {
    //             List<Prediction> predictions = await autoCompleteState().search(
    //               query,
    //               widget.apiKey,
    //               language: widget.language,
    //               sessionToken: widget.sessionToken,
    //               region: widget.region,
    //               components: widget.components,
    //               location: widget.location,
    //               offset: widget.offset,
    //               origin: widget.origin,
    //               radius: widget.radius,
    //               strictbounds: widget.strictbounds,
    //               types: widget.types,
    //             );
    //             return predictions;
    //           },
    //           onSuggestionSelected: (value) async {
    //             widget.searchController.selection = TextSelection.collapsed(
    //                 offset: widget.searchController.text.length);
    //             _getDetailsByPlaceId(value.placeId ?? "", context);
    //             widget.onSuggestionSelected?.call(value);
    //           },
    //           hideSuggestionsOnKeyboardHide:
    //               widget.hideSuggestionsOnKeyboardHide,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
