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
        
        switch call.method {
        case "initilizeSDK":
            if let key = call.arguments as? String {
                razorpayDelegate.initilizeSDK(withKey: key, result: result)
            }
        case "submit":
            if let options = call.arguments as? Dictionary<String, Any> {
                razorpayDelegate.submit(options: options, result: result);
            }
        case "changeApiKey":
            if let argument = call.arguments as? String {
                razorpayDelegate.changeApiKey(key: argument, result: result)
            }
        case "getBankLogoUrl":
            if let argument = call.arguments as? String {
                razorpayDelegate.getBankLogoUrl(value: argument, result: result)
            }
        case "getCardNetwork":
            if let argument = call.arguments as? String {
                razorpayDelegate.getCardNetwork(value: argument, result: result)
            }
        case "getPaymentMethods":
            razorpayDelegate.getPaymentMethods(result: result)
            
        case "getAppsWhichSupportUpi":
            razorpayDelegate.getAppsWhichSupportUpi(result: result)
            
        case "getSubscriptionAmount":
            if let value = call.arguments as? String {
                razorpayDelegate.getSubscriptionAmount(subscriptionId: value, result: result)
            }
        case "isValidCardNumber":
            if let arguments = call.arguments as? String {
                razorpayDelegate.isValidCardNumber(value: arguments, result: result)
            }
        case "isCredAppAvailable":
            razorpayDelegate.isCredAppAvailable(result: result)
            
        case "payWithCred":
            if let options = call.arguments as? Dictionary<String, Any> {
                razorpayDelegate.payWithCred(options: options, result: result)
            }
        case "getWalletLogoUrl":
            if let walletName = call.arguments as? String {
                razorpayDelegate.getWalletLogoUrl(value: walletName, result: result)
            }
        case "getCardNetworkLength":
            if let network = call.arguments as? String {
                razorpayDelegate.getCardNetworkLength(network: network, result: result)
            }
        case "isValidVpa":
            if let vpa = call.arguments as? String {
                razorpayDelegate.isValidVpa(value: vpa, result: result)
            }
        default:
            print("no method")
        }
    }
}
