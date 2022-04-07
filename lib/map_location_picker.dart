
import 'dart:async';

import 'package:flutter/services.dart';

class MapLocationPicker {
  static const MethodChannel _channel = MethodChannel('map_location_picker');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
