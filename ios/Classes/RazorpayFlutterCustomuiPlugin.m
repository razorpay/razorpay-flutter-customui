#import "RazorpayFlutterCustomuiPlugin.h"
#if __has_include(<razorpay_flutter_customui/razorpay_flutter_customui-Swift.h>)
#import <razorpay_flutter_customui/razorpay_flutter_customui-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "razorpay_flutter_customui-Swift.h"
#endif

@implementation RazorpayFlutterCustomuiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRazorpayFlutterCustomuiPlugin registerWithRegistrar:registrar];
}
@end
