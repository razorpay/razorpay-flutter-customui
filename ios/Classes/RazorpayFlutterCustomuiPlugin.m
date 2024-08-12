#import "RazorpayFlutterCustomuiPlugin.h"
#if __has_include(<razorpay_flutter_customui_turbo/razorpay_flutter_customui_turbo-Swift.h>)
#import <razorpay_flutter_customui_turbo/razorpay_flutter_customui_turbo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "razorpay_flutter_customui_turbo-Swift.h"
#endif

@implementation RazorpayFlutterCustomuiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRazorpayFlutterCustomuiPlugin registerWithRegistrar:registrar];
}
@end
