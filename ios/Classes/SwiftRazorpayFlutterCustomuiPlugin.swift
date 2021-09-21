import Flutter
import UIKit

public class SwiftRazorpayFlutterCustomuiPlugin: NSObject, FlutterPlugin {
    
    private var razorpayDelegate = RazorpayDelegate()
    private static var CHANNEL_NAME = "razorpay_flutter_customui";
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftRazorpayFlutterCustomuiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // result("iOS " + UIDevice.current.systemVersion)
        switch call.method {
        case "open":
            let options = call.arguments as? Dictionary<String, Any>
            razorpayDelegate.open(options: options ?? [:], result: result);
        case "changeApiKey":
            if let argument = call.arguments as? String {
                razorpayDelegate.changeApiKey(key: argument)
            }
        case "getBankLogoUrl":
            if let argument = call.arguments as? String {
                razorpayDelegate.getBankLogoUrl(value: argument)
            }
        case "getCardNetwork":
            if let argument = call.arguments as? String {
                razorpayDelegate.getCardNetwork(value: argument)
            }
        case "getPaymentMethods":
            if let options = call.arguments as? Dictionary<String, Any> {
                razorpayDelegate.getPaymentMethods(options: options)
            }
        case "getAppsWhichSupportUpi":
            razorpayDelegate.getAppsWhichSupportUpi()
            
        case "getSubscriptionAmount":
            if let arguments = call.arguments as? String {
                razorpayDelegate.getWalletLogoUrl(value: arguments)
            }
        case "isValidCardNumber":
            if let arguments = call.arguments as? String {
                razorpayDelegate.isValidCardNumber(value: arguments)
            }
        default:
            print("no method")
        }
    }
}
