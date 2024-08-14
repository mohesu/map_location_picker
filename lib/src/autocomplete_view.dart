import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:http/http.dart';

import '../map_location_picker.dart';
import 'logger.dart';

class PlacesAutocomplete extends StatelessWidget {
  /// API key for the map & places
  final String apiKey;

  /// Top card margin
  final EdgeInsetsGeometry topCardMargin;

  /// Top card color
  final Color? topCardColor;

  /// Top card shape
  final ShapeBorder topCardShape;

  /// Top card text field border radius
  final BorderRadiusGeometry borderRadius;

  /// Top card text field hint text
  final String searchHintText;

  /// Show back button (default: true)
  final bool hideBackButton;

  /// Back button replacement when [hideBackButton] is false and [backButton] is not null
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
  final num? offsetParameter;

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
  final void Function(Prediction)? onSelected;

  /// Search text field controller
  ///
  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? searchController;

  /// Is widget mounted
  final bool mounted;

  /// Can show clear button on search text field
  final bool showClearButton;

  /// suffix icon for search text field. You can use [showClearButton] to show clear button or replace with suffix icon
  final Widget? suffixIcon;

  /// Initial value for search text field (optional)
  /// [initialValue] not in use when [searchController] is not null.
  final Prediction? initialValue;

  /// Validator for search text field (optional)
  final String? Function(Prediction?)? validator;

  /// Called for each suggestion returned by [suggestionsCallback] to build the
  /// corresponding widget.
  ///
  /// This callback must not be null. It is called by the TypeAhead widget for
  /// each suggestion, and expected to build a widget to display this
  /// suggestion's info. For example:
  ///
  /// ```dart
  /// itemBuilder: (context, suggestion) {
  ///   return ListTile(
  ///     title: Text(suggestion['name']),
  ///     subtitle: Text('USD' + suggestion['price'].toString())
  ///   );
  /// }
  /// ```
  final Widget Function(BuildContext, Prediction)? itemBuilder;

  /// The duration to wait after the user stops typing before calling
  /// [suggestionsCallback]
  ///
  /// This is useful, because, if not set, a request for suggestions will be
  /// sent for every character that the user types.
  ///
  /// This duration is set by default to 300 milliseconds
  final Duration debounceDuration;

  /// Called when waiting for [suggestionsCallback] to return.
  ///
  /// It is expected to return a widget to display while waiting.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('Loading...');
  /// }
  /// ```
  ///
  /// If not specified, a [CircularProgressIndicator](https://docs.flutter.io/flutter/material/CircularProgressIndicator-class.html) is shown
  final WidgetBuilder? loadingBuilder;

  /// Called when [suggestionsCallback] throws an exception.
  ///
  /// It is called with the error object, and expected to return a widget to
  /// display when an exception is thrown
  /// For example:
  /// ```dart
  /// (BuildContext context, error) {
  ///   return Text('$error');
  /// }
  /// ```
  ///
  /// If not specified, the error is shown in [ThemeData.errorColor](https://docs.flutter.io/flutter/material/ThemeData/errorColor.html)
  final Widget Function(BuildContext, Object?)? errorBuilder;

  /// The duration that [transitionBuilder] animation takes.
  ///
  /// This argument is best used with [transitionBuilder] and [animationStart]
  /// to fully control the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  final VerticalDirection direction;

  final Widget Function(BuildContext, Animation<double>, Widget)?
      transitionBuilder;

  /// If set to true, no loading box will be shown while suggestions are
  /// being fetched. [loadingBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnLoading;

  /// If set to true, nothing will be shown if there are no results.
  /// [noItemsFoundBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnEmpty;

  /// If set to true, nothing will be shown if there is an error.
  /// [errorBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnError;

  /// If set to true, in the case where the suggestions box has less than
  /// _SuggestionsBoxController.minOverlaySpace to grow in the desired [direction], the direction axis
  /// will be temporarily flipped if there's more room available in the opposite
  /// direction.
  ///
  /// Defaults to false
  final bool autoFlipDirection;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// The suggestions box controller
  final ScrollController? scrollController;

  /// Input decoration for the text field
  final InputDecoration? decoration;

  /// value transformer
  final dynamic Function(Prediction?)? valueTransformer;

  /// Text input enabler
  final bool enabled;

  /// Auto-validate mode for the text field
  final AutovalidateMode autovalidateMode;

  /// on change callback
  final void Function(Prediction?)? onChanged;

  /// on reset callback
  final void Function()? onReset;

  /// on form save callback
  final void Function(Prediction?)? onSaved;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Safe area parameters
  final bool bottom;
  final bool left;
  final bool maintainBottomViewPadding;
  final EdgeInsets minimum;
  final bool right;
  final bool top;

  /// Minimum number of characters to trigger suggestions
  /// Defaults to 0
  final int minCharsForSuggestions;

  final bool autoFlipListDirection;
  final double autoFlipMinHeight;
  final BoxConstraints? constraints;
  final TextField? customTextField;
  final Widget Function(BuildContext, Widget)? decorationBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final bool hideKeyboardOnDrag;
  final bool hideOnSelect;
  final bool hideOnUnfocus;
  final bool hideWithKeyboard;
  final Widget Function(BuildContext, int)? itemSeparatorBuilder;
  final Widget Function(BuildContext, List<Widget>)? listBuilder;
  final Offset? offset;
  final bool retainOnLoading;
  final bool showOnFocus;
  final SuggestionsController<Prediction>? suggestionsController;

  const PlacesAutocomplete({
    super.key,
    required this.apiKey,
    this.language,
    this.topCardMargin = const EdgeInsets.all(8),
    this.topCardColor,
    this.topCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.searchHintText = "Start typing to search",
    this.hideBackButton = false,
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
    this.searchController,
    required this.mounted,
    this.onGetDetailsByPlaceId,
    this.onSelected,
    this.showClearButton = true,
    this.suffixIcon,
    this.initialValue,
    this.validator,
    this.itemBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.autoFlipDirection = false,
    this.controller,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.direction = VerticalDirection.down,
    this.errorBuilder,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideOnLoading = false,
    this.loadingBuilder,
    this.scrollController,
    this.decoration,
    this.valueTransformer,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.onReset,
    this.onSaved,
    this.focusNode,
    this.minimum = EdgeInsets.zero,
    this.bottom = true,
    this.left = true,
    this.maintainBottomViewPadding = false,
    this.right = true,
    this.top = true,
    this.minCharsForSuggestions = 0,
    this.transitionBuilder,
    this.autoFlipListDirection = true,
    this.autoFlipMinHeight = 64.0,
    this.constraints,
    this.customTextField,
    this.decorationBuilder,
    this.emptyBuilder,
    this.hideKeyboardOnDrag = false,
    this.hideOnSelect = true,
    this.hideOnUnfocus = true,
    this.hideWithKeyboard = true,
    this.itemSeparatorBuilder,
    this.listBuilder,
    this.retainOnLoading = true,
    this.showOnFocus = true,
    this.suggestionsController,
    this.offsetParameter,
  });

  /// Get [AutoCompleteState] for [AutoCompleteTextField]
  AutoCompleteState autoCompleteState() {
    return AutoCompleteState(
      apiHeaders: placesApiHeaders,
      baseUrl: placesBaseUrl,
      httpClient: placesHttpClient,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Get text controller from [searchController] or create new instance of [TextEditingController] if [searchController] is null or empty
    final textController = useState<TextEditingController>(
        searchController ?? TextEditingController());
    return SafeArea(
      bottom: bottom,
      left: left,
      maintainBottomViewPadding: maintainBottomViewPadding,
      minimum: minimum,
      right: right,
      top: top,
      child: Card(
        margin: topCardMargin,
        shape: topCardShape,
        color: topCardColor,
        child: ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.only(right: 4, left: 4),
          leading: hideBackButton ? null : backButton ?? const BackButton(),
          title: ClipRRect(
            borderRadius: borderRadius,
            child: FormBuilderTypeAhead<Prediction>(
              decoration: decoration ??
                  InputDecoration(
                    hintText: searchHintText,
                    border: InputBorder.none,
                    filled: true,
                    suffixIcon: (showClearButton && initialValue == null)
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => textController.value.clear(),
                          )
                        : suffixIcon,
                  ),
              name: 'Search',
              controller: initialValue == null ? textController.value : null,
              selectionToTextTransformer: (result) {
                return result.description ?? "";
              },
              itemBuilder: itemBuilder ??
                  (context, content) {
                    return ListTile(
                      title: Text(content.description ?? ""),
                    );
                  },
              suggestionsCallback: (query) async {
                List<Prediction> predictions = await autoCompleteState().search(
                  query,
                  apiKey,
                  language: language,
                  sessionToken: sessionToken,
                  region: region,
                  components: components,
                  location: location,
                  offset: offsetParameter,
                  origin: origin,
                  radius: radius,
                  strictbounds: strictbounds,
                  types: types,
                );
                return predictions;
              },
              onSelected: (value) async {
                textController.value.selection = TextSelection.collapsed(
                    offset: textController.value.text.length);
                _getDetailsByPlaceId(value.placeId ?? "", context);
                onSelected?.call(value);
              },
              initialValue: initialValue,
              validator: validator,
              scrollController: scrollController,
              animationDuration: animationDuration,
              autoFlipDirection: autoFlipDirection,
              debounceDuration: debounceDuration,
              direction: direction,
              errorBuilder: errorBuilder,
              focusNode: focusNode,
              hideOnEmpty: hideOnEmpty,
              hideOnError: hideOnError,
              hideOnLoading: hideOnLoading,
              loadingBuilder: loadingBuilder,
              transitionBuilder: transitionBuilder,
              valueTransformer: valueTransformer,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
              onChanged: onChanged,
              onReset: onReset,
              onSaved: onSaved,
              key: key,
              autoFlipListDirection: autoFlipListDirection,
              autoFlipMinHeight: autoFlipMinHeight,
              constraints: constraints,
              customTextField: customTextField,
              decorationBuilder: decorationBuilder,
              emptyBuilder: emptyBuilder,
              hideKeyboardOnDrag: hideKeyboardOnDrag,
              hideOnSelect: hideOnSelect,
              hideOnUnfocus: hideOnUnfocus,
              hideWithKeyboard: hideWithKeyboard,
              itemSeparatorBuilder: itemSeparatorBuilder,
              listBuilder: listBuilder,
              offset: offset,
              retainOnLoading: retainOnLoading,
              showOnFocus: showOnFocus,
              suggestionsController: suggestionsController,
            ),
          ),
        ),
      ),
    );
  }

  /// Get address details from place id
  void _getDetailsByPlaceId(String placeId, BuildContext context) async {
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
      onGetDetailsByPlaceId?.call(response);
    } catch (e) {
      logger.e(e);
    }
  }
}
