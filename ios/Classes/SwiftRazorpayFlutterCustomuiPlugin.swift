import Flutter
import UIKit

public class SwiftRazorpayFlutterCustomuiPlugin: NSObject, FlutterPlugin {
    
    private var razorpayDelegate = RazorpayDelegate()
    private static var CHANNEL_NAME = "razorpay_flutter_customui";
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftRazorpayFlutterCustomuiPlugin()
        // Apps on the UIScene lifecycle (default for newer Flutter templates) get openURL via
        // scene(_:openURLContexts:). addSceneDelegate / FlutterSceneLifeCycleDelegate only exist on
        // newer Flutter engines, so register dynamically to keep building on older ones. The protocol
        // is attached before any registration so the engine sees scene support from the start.
        if #available(iOS 13.0, *) {
            let addSceneDelegateSel = NSSelectorFromString("addSceneDelegate:")
            let registrarObject = registrar as AnyObject
            if registrarObject.responds(to: addSceneDelegateSel) {
                if let sceneProtocol = NSProtocolFromString("FlutterSceneLifeCycleDelegate") {
                    class_addProtocol(SwiftRazorpayFlutterCustomuiPlugin.self, sceneProtocol)
                }
                _ = registrarObject.perform(addSceneDelegateSel, with: instance)
            }
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
        // Apps on the classic AppDelegate lifecycle get openURL here. Either path forwards Amazon
        // Pay's amzn-<bundle id>:// redirect to the Amazon SDK, so the merchant needs no AppDelegate code.
        registrar.addApplicationDelegate(instance)
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        return RazorpayDelegate.handleAmazonPayRedirect(url, sourceApplication: sourceApplication)
    }

    @available(iOS 13.0, *)
    @objc public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        var handled = false
        for context in URLContexts where RazorpayDelegate.handleAmazonPayRedirect(context.url, sourceApplication: context.options.sourceApplication) {
            handled = true
        }
        return handled
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

        case "getRecommendedInstruments":
            let options = call.arguments as? [String: Any] ?? [:]
            razorpayDelegate.getRecommendedInstruments(options: options, result: result)

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
        case "amazonPayStartAuthorization":
            if let args = call.arguments as? Dictionary<String, Any>,
               let customerId = args["customerId"] as? String {
                razorpayDelegate.amazonPayStartAuthorization(customerId: customerId, result: result)
            }
        case "isAmazonPayAvailable":
            razorpayDelegate.isAmazonPayAvailable(result: result)
        default:
            print("no method")
        }
    }
}
