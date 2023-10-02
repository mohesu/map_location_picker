# map_location_picker:

[![Pub Version](https://img.shields.io/pub/v/map_location_picker?color=blue&style=plastic)](https://pub.dev/packages/map_location_picker)
[![GitHub Repo stars](https://img.shields.io/github/stars/mohesu/map_location_picker?color=gold&style=plastic)](https://github.com/mohesu/map_location_picker/stargazers)
[![GitHub Repo forks](https://img.shields.io/github/forks/mohesu/map_location_picker?color=slateblue&style=plastic)](https://github.com/mohesu/map_location_picker/fork)
[![GitHub Repo issues](https://img.shields.io/github/issues/rvndsngwn/map_location_picker?color=coral&style=plastic)](https://github.com/mohesu/map_location_picker/issues)
[![GitHub Repo contributors](https://img.shields.io/github/contributors/rvndsngwn/map_location_picker?color=green&style=plastic)](https://github.com/mohesu/map_location_picker/graphs/contributors)

# A simple library to pick a location on a map.

Made by Arvind [@rvndsngwn](https://github.com/rvndsngwn):

- Compatibility with Geolocator
- Use of Google map APIs
- Added support for flutter web
- All new customizations are done in the `GoogleMapLocationPicker` class

## 📸 Screenshots
Location picker using the official [google_maps_flutter](https://pub.dev/packages/google_maps_flutter).

I made This plugin because google deprecated [Place Picker](https://developers.google.com/places/android-sdk/placepicker).

<table>
  <tr>
    <td>Video </td>
     <td>Decoded Address</td>
     <td>Places autocomplete</td>
  </tr>
  <tr>
<td><img src="https://raw.githubusercontent.com/rvndsngwn/map_location_picker/master/assets/GIF_4300.gif" width=270 height=480 alt=""></td>
<td><img src="https://raw.githubusercontent.com/rvndsngwn/map_location_picker/master/assets/IMG_2480.PNG" width=270 height=480 alt=""></td>
<td><img src="https://raw.githubusercontent.com/rvndsngwn/map_location_picker/master/assets/IMG_2482.PNG" width=270 height=480 alt=""></td>
</tr>
</table>

## Setup

Pubspec changes:

```
      dependencies:
        map_location_picker: ^1.3.0-beta
```
You can now add a `GoogleMap` widget to your widget tree.

```dart
import 'package:map_location_picker/map_location_picker.dart';

GoogleMapLocationPicker(
  apiKey: "YOUR_API_KEY",
  onNext: (GeocodingResult? result) {
      ...
   },
);
```

## Getting Started

- Get an API key at <https://cloud.google.com/maps-platform/>.

- And don't forget to enable the following APIs in <https://console.cloud.google.com/google/maps-apis/>

  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API
  - Geocoding API
  - Maps JavaScript API

- And ensure to enable billing for the project.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 20
    }
}
```

This means that app will only be available for users that run Android SDK 20 or higher.

2. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

#### Hybrid Composition

To use [Hybrid Composition](https://flutter.dev/docs/development/platform-integration/platform-views)
to render the `GoogleMap` widget on Android, set `AndroidGoogleMapsFlutter.useAndroidViewSurface` to
true.

```dart
if (defaultTargetPlatform == TargetPlatform.android) {
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
}
```

### iOS

To set up, specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Web View

Modify `web/index.html`

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).

Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:

```html
<head>
  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
</head>
```

### Note

The following permissions are not required to use Google Maps Android API v2, but are recommended.

`android.permission.ACCESS_COARSE_LOCATION` Allows the API to use WiFi or mobile cell data (or both) to determine the device's location. The API returns the location with an accuracy approximately equivalent to a city block.

`android.permission.ACCESS_FINE_LOCATION` Allows the API to determine as precise a location as possible from the available location providers, including the Global Positioning System (GPS) as well as WiFi and mobile cell data.

---

You must also explicitly declare that your app uses the android.hardware.location.network or android.hardware.location.gps hardware features if your app targets Android 5.0 (API level 21) or higher and uses the ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION permission in order to receive location updates from the network or a GPS, respectively.

```xml
<uses-feature android:name="android.hardware.location.network" android:required="false" />
<uses-feature android:name="android.hardware.location.gps" android:required="false"  />
```

---

The following permissions are defined in the package manifest, and are automatically merged into your app's manifest at build time. You **don't** need to add them explicitly to your manifest:

`android.permission.INTERNET` Used by the API to download map tiles from Google Maps servers.

`android.permission.ACCESS_NETWORK_STATE` Allows the API to check the connection status in order to determine whether data can be downloaded.

## Restricting Autocomplete Search to Region

The `Result`s returned can be restricted to certain countries by passing an array of country codes into the `components` parameter of `MapLocationPicker`. Countries must be two character, `ISO 3166-1 Alpha-2` compatible.
You can find code information at [Wikipedia: List of ISO 3166 country codes](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) or the [ISO Online Browsing Platform](https://www.iso.org/obp/ui/#search).

The example below restricts Autocomplete Search to the United Arab Emirates and Nigeria

```dart
GoogleMapLocationPicker(
 apiKey: "YOUR_API_KEY",
 onNext: (GeocodingResult? result) {
   ...
  },
);
```

See the `example` directory for a complete sample app.


### Parameters of the MapLocationPicker

```dart
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

/// Search text field controller
final SearchController? searchController;

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
```
## 💰You can help me by Donating

[![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/rvndsngwn) [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/rvndsngwn?country.x=IN&locale.x=en_GB) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/rvndsngwn)

## 👨🏻‍💻Contribute to the project
All contributions are welcome.

[![GitHub](https://img.shields.io/badge/GitHub-0f0f0f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/mohesu/map_location_picker)
