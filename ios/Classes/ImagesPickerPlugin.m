#import "ImagesPickerPlugin.h"
#if __has_include(<images_picker/images_picker-Swift.h>)
#import <images_picker/images_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "images_picker-Swift.h"
#endif

@implementation ImagesPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImagesPickerPlugin registerWithRegistrar:registrar];
}
@end
