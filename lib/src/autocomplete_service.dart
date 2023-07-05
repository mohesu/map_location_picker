import "package:google_maps_webapi/places.dart";
import 'package:http/http.dart';

import 'logger.dart';

class AutoCompleteState {
  /// httpClient is used to make network requests.
  final Client? httpClient;

  /// apiHeader is used to add headers to the request.
  final Map<String, String>? apiHeaders;

  /// baseUrl is used to build the url for the request.
  final String? baseUrl;

  /// The current state of the autocomplete.
  List<Prediction> predictions = [];

  AutoCompleteState({
    this.httpClient,
    this.apiHeaders,
    this.baseUrl,
  });

  /// void future function to get the autocomplete results.
  Future<List<Prediction>> search(
    /// final String input,
    String query,

    /// API key for Google Places API
    String apiKey, {
    /// Session token for Google Places API
    String? sessionToken,

    /// Offset for pagination of results
    /// offset: int,
    num? offset,

    /// Origin location for calculating distance from results
    /// origin: Location(lat: -33.852, lng: 151.211),
    Location? origin,

    /// Location bounds for restricting results to a radius around a location
    /// location: Location(lat: -33.867, lng: 151.195)
    Location? location,

    /// Radius for restricting results to a radius around a location
    /// radius: Radius in meters
    num? radius,

    /// Language code for Places API results
    /// language: 'en',
    String? language,

    /// Types for restricting results to a set of place types
    List<String> types = const [],

    /// Components set results to be restricted to a specific area
    /// components: [Component(Component.country, "us")]
    List<Component> components = const [],

    /// Bounds for restricting results to a set of bounds
    bool strictbounds = false,

    /// Region for restricting results to a set of regions
    /// region: "us"
    String? region,
  }) async {
    try {
      final places = GoogleMapsPlaces(
        apiKey: apiKey,
        httpClient: httpClient,
        apiHeaders: apiHeaders,
        baseUrl: baseUrl,
      );
      final PlacesAutocompleteResponse response = await places.autocomplete(
        query,
        region: region,
        language: language,
        components: components,
        location: location,
        offset: offset,
        origin: origin,
        radius: radius,
        sessionToken: sessionToken,
        strictbounds: strictbounds,
        types: types,
      );

      /// When get any error from the API, show the error in the console.
      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        if (query.isNotEmpty) {
          logger.e(response.errorMessage);
        }
        return [];
      }

      /// Update the results with the new results.
      predictions = response.predictions;

      logger.d(predictions.map((e) => e.toJson()).toList());

      /// Return the results.
      return predictions;
    } catch (err) {
      /// Log the error
      logger.e(err);
      return [];
    }
  }
}
