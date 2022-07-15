#import "BiometricsPlugin.h"
#if __has_include(<biometrics/biometrics-Swift.h>)
#import <biometrics/biometrics-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "biometrics-Swift.h"
#endif

@implementation BiometricsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBiometricsPlugin registerWithRegistrar:registrar];
}
@end
