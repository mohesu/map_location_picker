#import "MapLocationPickerPlugin.h"
#if __has_include(<map_location_picker/map_location_picker-Swift.h>)
#import <map_location_picker/map_location_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "map_location_picker-Swift.h"
#endif

@implementation MapLocationPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMapLocationPickerPlugin registerWithRegistrar:registrar];
}
@end
