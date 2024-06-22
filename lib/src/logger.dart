import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

const Level loggerLevel = Level.trace;

/// Logger for the app.
Logger logger = Logger(
  /// Logger level.
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 90,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
  level: loggerLevel,
);

ValueNotifier<T> useState<T>(T initialData) {
  return ValueNotifier<T>(initialData);
}