import 'package:logger/logger.dart';

var loggerLevel = Level.verbose;

/// Logger for the app.
Logger logger = Logger(

    /// Logger level.
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 90,
      colors: false,
      printEmojis: true,
      printTime: false,
    ),
    level: loggerLevel);
