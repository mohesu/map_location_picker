import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../map_location_picker.dart';
import 'logger.dart';

class PlacesAutocomplete extends StatelessWidget {
  /// Whether the search view grows to fill the entire screen when the
  /// [SearchAnchor] is tapped.
  ///
  /// By default, the search view is full-screen on mobile devices. On other
  /// platforms, the search view only grows to a specific size that is determined
  /// by the anchor and the default size.
  final bool? isFullScreen;

  /// An optional controller that allows opening and closing of the search view from
  /// other widgets.
  ///
  /// If this is null, one internal search controller is created automatically
  /// and it is used to open the search view when the user taps on the anchor.
  final SearchController? searchController;


  /// An optional widget to display before the text input field when the search
  /// view is open.
  ///
  /// Typically the [viewLeading] widget is an [Icon] or an [IconButton].
  ///
  /// Defaults to a back button which pops the view.
  final Widget? viewLeading;

  /// An optional widget list to display after the text input field when the search
  /// view is open.
  ///
  /// Typically the [viewTrailing] widget list only has one or two widgets.
  ///
  /// Defaults to an icon button which clears the text in the input field.
  final Iterable<Widget>? viewTrailing;

  /// Text that is displayed when the search bar's input field is empty.
  final String? viewHintText;

  /// The search view's background fill color.
  ///
  /// If null, the value of [SearchViewThemeData.backgroundColor] will be used.
  /// If this is also null, then the default value is [ColorScheme.surface].
  final Color? viewBackgroundColor;

  /// The elevation of the search view's [Material].
  ///
  /// If null, the value of [SearchViewThemeData.elevation] will be used. If this
  /// is also null, then default value is 6.0.
  final double? viewElevation;


  /// The color and weight of the search view's outline.
  ///
  /// This value is combined with [viewShape] to create a shape decorated
  /// with an outline. This will be ignored if the view is full-screen.
  ///
  /// If null, the value of [SearchViewThemeData.side] will be used. If this is
  /// also null, the search view doesn't have a side by default.
  final BorderSide? viewSide;

  /// The shape of the search view's underlying [Material].
  ///
  /// This shape is combined with [viewSide] to create a shape decorated
  /// with an outline.
  ///
  /// If null, the value of [SearchViewThemeData.shape] will be used.
  /// If this is also null, then the default value is a rectangle shape for full-screen
  /// mode and a [RoundedRectangleBorder] shape with a 28.0 radius otherwise.
  final OutlinedBorder? viewShape;

  /// The style to use for the text being edited on the search view.
  ///
  /// If null, defaults to the `bodyLarge` text style from the current [Theme].
  /// The default text color is [ColorScheme.onSurface].
  final TextStyle? headerTextStyle;

  /// The style to use for the [viewHintText] on the search view.
  ///
  /// If null, the value of [SearchViewThemeData.headerHintStyle] will be used.
  /// If this is also null, the value of [headerTextStyle] will be used. If this is also null,
  /// defaults to the `bodyLarge` text style from the current [Theme]. The default
  /// text color is [ColorScheme.onSurfaceVariant].
  final TextStyle? headerHintStyle;

  /// The color of the divider on the search view.
  ///
  /// If this property is null, then [SearchViewThemeData.dividerColor] is used.
  /// If that is also null, the default value is [ColorScheme.outline].
  final Color? dividerColor;

  /// Optional size constraints for the search view.
  ///
  /// By default, the search view has the same width as the anchor and is 2/3
  /// the height of the screen. If the width and height of the view are within
  /// the [viewConstraints], the view will show its default size. Otherwise,
  /// the size of the view will be constrained by this property.
  ///
  /// If null, the value of [SearchViewThemeData.constraints] will be used. If
  /// this is also null, then the constraints defaults to:
  /// ```dart
  /// const BoxConstraints(minWidth: 360.0, minHeight: 240.0)
  /// ```
  final BoxConstraints? viewConstraints;


  /// Called to get the suggestion list for the search view.
  ///
  /// By default, the list returned by this builder is laid out in a [ListView].
  /// [suggestionsBuilder] is overridden the [listBuilder]
  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)?
      suggestionsBuilder;

  /// Called to get the suggestion list for the search view.
  ///
  /// By default, the list returned by this builder is laid out in a [ListView].
  /// [suggestionsBuilder] is overridden the [listBuilder]
  final Widget Function(BuildContext, List<Prediction>?)? listBuilder;

  /// Search bar shape (optional)
  final MaterialStateProperty<OutlinedBorder?>? barShape;

  /// Search bar elevation (optional)
  final MaterialStateProperty<double?>? barElevation;


  final void Function()? onTap;

  final MaterialStateProperty<Color?>? barBackgroundColor;

  final MaterialStateProperty<TextStyle?>? barHintStyle;

  final Widget? barLeading;

  final MaterialStateProperty<Color?>? barOverlayColor;


  final MaterialStateProperty<TextStyle?>? barTextStyle;

  final Iterable<Widget>? barTrailing;

  final BoxConstraints? constraints;

  final MaterialStateProperty<EdgeInsetsGeometry?>? barPadding;

  final MaterialStateProperty<BorderSide?>? barSide;

  /// API key for the map & places API (required)
  final String apiKey;

  /// Top card text field border radius
  final BorderRadiusGeometry borderRadius;

  /// Top card text field hint text
  final String searchHintText;

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

  /// On get details callback
  final void Function(PlacesDetailsResponse?)? onGetDetailsByPlaceId;

  /// On suggestion selected callback
  final void Function(Prediction)? onSuggestionSelected;

  /// Validator for search text field (optional)
  final String? Function(Prediction?)? validator;

  const PlacesAutocomplete({
    Key? key,
    required this.apiKey,
    this.language,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.searchHintText = "Start typing to search",
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
    this.onGetDetailsByPlaceId,
    this.onSuggestionSelected,
    this.validator,
    this.isFullScreen,
    this.searchController ,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSide,
    this.viewShape,
    this.headerTextStyle,
    this.headerHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.suggestionsBuilder,
    this.listBuilder,
    this.barShape,
    this.barElevation,
    this.onTap,
    this.barBackgroundColor,
    this.barHintStyle,
    this.barLeading,
    this.barOverlayColor,
    this.barTextStyle,
    this.barTrailing,
    this.constraints,
    this.barPadding,
    this.barSide,
  }) : super(key: key);

  /// Get [AutoCompleteState] for [AutoCompleteTextField]
  AutoCompleteState get autoCompleteState => AutoCompleteState(
        apiHeaders: placesApiHeaders,
        baseUrl: placesBaseUrl,
        httpClient: placesHttpClient,
      );

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      isFullScreen: isFullScreen ?? false,
      barShape: barShape ??
          MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: borderRadius),
          ),
      viewConstraints: viewConstraints ?? const BoxConstraints(maxHeight: 300),
      barElevation: barElevation ?? MaterialStateProperty.all(2),
      viewElevation: viewElevation ?? 220,
      barHintText: searchHintText,
      onTap: onTap,
      searchController: searchController ?? SearchController(),
      barBackgroundColor: barBackgroundColor,
      barHintStyle: barHintStyle,
      barLeading: barLeading,
      barOverlayColor: barOverlayColor,
      barPadding: barPadding,
      barSide: barSide,
      barTextStyle: barTextStyle,
      barTrailing: barTrailing,
      constraints: constraints,
      dividerColor: dividerColor,
      viewBackgroundColor: viewBackgroundColor,
      viewHeaderHintStyle: headerHintStyle,
      viewHeaderTextStyle: headerTextStyle,
      viewHintText: viewHintText,
      viewLeading: viewLeading,
      viewShape: viewShape,
      viewSide: viewSide,
      viewTrailing: viewTrailing,
      suggestionsBuilder: suggestionsBuilder ??
          (context, controller) {
            final searchFuture = autoCompleteState.search(
              controller.text,
              apiKey,
              language: language,
              sessionToken: sessionToken,
              region: region,
              components: components,
              location: location,
              offset: offset,
              origin: origin,
              radius: radius,
              strictbounds: strictbounds,
              types: types,
            );
            return [
              FutureBuilder(
                future: searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final List<Prediction>? predictions = snapshot.data;
                    if (predictions == null) {
                      return const Text("No results found");
                    }
                    return listBuilder?.call(context, predictions) ??
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: predictions.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Prediction prediction = predictions[index];
                            return ListTile(
                              minVerticalPadding: 0,
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                _getDetailsByPlaceId(
                                  prediction.placeId ?? "",
                                  context,
                                );
                                onSuggestionSelected?.call(prediction);
                                controller.text = prediction.description ?? "";
                                FocusScope.of(context).unfocus();
                              },
                              title: Text(prediction.description ??
                                  prediction.structuredFormatting?.mainText ??
                                  "No title"),
                            );
                          },
                        );
                  }
                  return const LinearProgressIndicator();
                },
              ),
            ];
          },
    );
  }

  /// Get address details from place id
  Future<void> _getDetailsByPlaceId(
    String placeId,
    BuildContext context,
  ) async {
    try {
      final GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: apiKey,
        httpClient: placesHttpClient,
        apiHeaders: placesApiHeaders,
        baseUrl: placesBaseUrl,
      );
      final PlacesDetailsResponse response = await places.getDetailsByPlaceId(
        placeId,
        region: region,
        sessionToken: sessionToken,
        language: language,
        fields: fields,
      );

      /// When get any error from the API, show the error in the console.
      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        logger.e(response.errorMessage);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ??
                  "Address not found, something went wrong!"),
            ),
          );
        }
        return;
      }
      onGetDetailsByPlaceId?.call(response);
    } catch (e) {
      logger.e(e);
    }
  }
}
