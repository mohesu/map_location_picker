/*
import 'dart:io';

import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';

import '../../logger.dart';

class LocationUtils {
  static const _platform = MethodChannel('google_map_location_picker');
  static Map<String, String> _appHeaderCache = {};

  static Future<Map<String, String>> getAppHeaders() async {
    if (_appHeaderCache.isEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isIOS) {
        _appHeaderCache = {
          "X-Ios-Bundle-Identifier": packageInfo.packageName,
        };
      } else if (Platform.isAndroid) {
        String sha1 = "";
        try {
          sha1 = await _platform.invokeMethod(
              'getSigningCertSha1', packageInfo.packageName);
        } on PlatformException {
          _appHeaderCache = {};
          logger.e(
              "Failed to get signing cert sha1 for ${packageInfo.packageName}");
        }

        _appHeaderCache = {
          "X-Android-Package": packageInfo.packageName,
          "X-Android-Cert": sha1,
        };
      }
    }

    return _appHeaderCache;
  }
}
*/
