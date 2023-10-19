import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart' hide ErrorBuilder;
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:http/http.dart';

import '../map_location_picker.dart';
import 'logger.dart';

ValueNotifier<T> useState<T>(T initialData) {
  return ValueNotifier<T>(initialData);
}

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

  /// The decoration of the material sheet that contains the suggestions.
  ///
  /// If null, default decoration with an elevation of 4.0 is used
  final SuggestionsBoxDecoration suggestionsBoxDecoration;

  /// Used to control the `_SuggestionsBox`. Allows manual control to
  /// open, close, toggle, or resize the `_SuggestionsBox`.
  final SuggestionsBoxController? suggestionsBoxController;

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

  /// Called when [suggestionsCallback] returns an empty array.
  ///
  /// It is expected to return a widget to display when no suggestions are
  /// available.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('No Items Found!');
  /// }
  /// ```
  ///
  /// If not specified, a simple text is shown
  final WidgetBuilder? noItemsFoundBuilder;

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

  /// Called to display animations when [suggestionsCallback] returns suggestions
  ///
  /// It is provided with the suggestions box instance and the animation
  /// controller, and expected to return some animation that uses the controller
  /// to display the suggestion box.
  ///
  /// For example:
  /// ```dart
  /// transitionBuilder: (context, suggestionsBox, animationController) {
  ///   return FadeTransition(
  ///     child: suggestionsBox,
  ///     opacity: CurvedAnimation(
  ///       parent: animationController,
  ///       curve: Curves.fastOutSlowIn
  ///     ),
  ///   );
  /// }
  /// ```
  /// This argument is best used with [animationDuration] and [animationStart]
  /// to fully control the animation.
  ///
  /// To fully remove the animation, just return `suggestionsBox`
  ///
  /// If not specified, a [SizeTransition](https://docs.flutter.io/flutter/widgets/SizeTransition-class.html) is shown.
  final AnimationTransitionBuilder? transitionBuilder;

  /// The duration that [transitionBuilder] animation takes.
  ///
  /// This argument is best used with [transitionBuilder] and [animationStart]
  /// to fully control the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Determine the [SuggestionBox]'s direction.
  ///
  /// If [AxisDirection.down], the [SuggestionBox] will be below the [TextField]
  /// and the [_SuggestionsList] will grow **down**.
  ///
  /// If [AxisDirection.up], the [SuggestionBox] will be above the [TextField]
  /// and the [_SuggestionsList] will grow **up**.
  ///
  /// [AxisDirection.left] and [AxisDirection.right] are not allowed.
  final AxisDirection direction;

  /// The value at which the [transitionBuilder] animation starts.
  ///
  /// This argument is best used with [transitionBuilder] and [animationDuration]
  /// to fully control the animation.
  ///
  /// Defaults to 0.25.
  final double animationStart;

  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the TypeAhead widget displays
  final TextFieldConfiguration textFieldConfiguration;

  /// How far below the text field should the suggestions box be
  ///
  /// Defaults to 5.0
  final double suggestionsBoxVerticalOffset;

  /// If set to true, suggestions will be fetched immediately when the field is
  /// added to the view.
  ///
  /// But the suggestions box will only be shown when the field receives focus.
  /// To make the field receive focus immediately, you can set the `autofocus`
  /// property in the [textFieldConfiguration] to true
  ///
  /// Defaults to false
  final bool getImmediateSuggestions;

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

  /// If set to false, the suggestions box will stay opened after
  /// the keyboard is closed.
  ///
  /// Defaults to true.
  final bool hideSuggestionsOnKeyboardHide;

  /// If set to false, the suggestions box will show a circular
  /// progress indicator when retrieving suggestions.
  ///
  /// Defaults to true.
  final bool keepSuggestionsOnLoading;

  /// If set to true, the suggestions box will remain opened even after
  /// selecting a suggestion.
  ///
  /// Note that if this is enabled, the only way
  /// to close the suggestions box is either manually via the
  /// `SuggestionsBoxController` or when the user closes the software
  /// keyboard if `hideSuggestionsOnKeyboardHide` is set to true. Users
  /// with a physical keyboard will be unable to close the
  /// box without a manual way via `SuggestionsBoxController`.
  ///
  /// Defaults to false.
  final bool keepSuggestionsOnSuggestionSelected;

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

  /// Hide the keyboard when a suggestion is selected
  final bool hideKeyboard;

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

  const PlacesAutocomplete({
    Key? key,
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
    this.hideSuggestionsOnKeyboardHide = false,
    this.searchController,
    required this.mounted,
    this.onGetDetailsByPlaceId,
    this.onSuggestionSelected,
    this.showClearButton = true,
    this.suffixIcon,
    this.initialValue,
    this.validator,
    this.itemBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationStart = 0.25,
    this.autoFlipDirection = false,
    this.controller,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.direction = AxisDirection.down,
    this.errorBuilder,
    this.getImmediateSuggestions = false,
    this.hideKeyboard = false,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideOnLoading = false,
    this.keepSuggestionsOnLoading = true,
    this.keepSuggestionsOnSuggestionSelected = false,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.scrollController,
    this.suggestionsBoxController,
    this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    this.suggestionsBoxVerticalOffset = 5.0,
    this.textFieldConfiguration = const TextFieldConfiguration(),
    this.transitionBuilder,
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
  }) : super(key: key);

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
    final textController =
        useState<TextEditingController>(searchController ?? TextEditingController());
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
              minCharsForSuggestions: minCharsForSuggestions,
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
                  offset: offset,
                  origin: origin,
                  radius: radius,
                  strictbounds: strictbounds,
                  types: types,
                );
                return predictions;
              },
              onSuggestionSelected: (value) async {
                textController.value.selection =
                    TextSelection.collapsed(offset: textController.value.text.length);
                _getDetailsByPlaceId(value.placeId ?? "", context);
                onSuggestionSelected?.call(value);
              },
              hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
              initialValue: initialValue,
              validator: validator,
              suggestionsBoxDecoration: suggestionsBoxDecoration,
              scrollController: scrollController,
              animationDuration: animationDuration,
              animationStart: animationStart,
              autoFlipDirection: autoFlipDirection,
              debounceDuration: debounceDuration,
              direction: direction,
              errorBuilder: errorBuilder,
              focusNode: focusNode,
              getImmediateSuggestions: getImmediateSuggestions,
              hideKeyboard: hideKeyboard,
              hideOnEmpty: hideOnEmpty,
              hideOnError: hideOnError,
              hideOnLoading: hideOnLoading,
              keepSuggestionsOnLoading: keepSuggestionsOnLoading,
              keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected,
              loadingBuilder: loadingBuilder,
              noItemsFoundBuilder: noItemsFoundBuilder,
              suggestionsBoxController: suggestionsBoxController,
              suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
              textFieldConfiguration: textFieldConfiguration,
              transitionBuilder: transitionBuilder,
              valueTransformer: valueTransformer,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
              onChanged: onChanged,
              onReset: onReset,
              onSaved: onSaved,
              key: key,
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
              content: Text(response.errorMessage ?? "Address not found, something went wrong!"),
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
