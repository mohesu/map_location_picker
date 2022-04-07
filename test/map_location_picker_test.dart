import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

void main() {
  const MethodChannel channel = MethodChannel('map_location_picker');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await MapLocationPicker.platformVersion, '42');
  });
}
