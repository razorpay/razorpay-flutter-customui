import Flutter
import UIKit

public class SwiftRazorpayFlutterCustomuiPlugin: NSObject, FlutterPlugin {

    private var razorpayDelegate = RazorpayDelegate()
    private static var CHANNEL_NAME = "razorpay_turbo";
    
    private var eventSink: FlutterEventSink!
    private static var TURBO_CHANNEL_NAME = "razorpay_turbo_with_turbo_upi"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftRazorpayFlutterCustomuiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: TURBO_CHANNEL_NAME, binaryMessenger: registrar.messenger()) // timeHandlerEvent is event name
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "initilizeSDK":
            if let key = call.arguments as? String {
                razorpayDelegate.initilizeSDK(withKey: key, ui: false, result: result)
            } else if let options = call.arguments as? Dictionary<String, Any> {
               if let key = options["key"] as? String, let ui = options["ui"] as? Bool {
                razorpayDelegate.initilizeSDK(withKey: key, ui: ui, result: result)
               }
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
            // MARK: Turbo Methods
        case "linkNewUpiAccount":
            if let customerMobile = call.arguments as? String {
                razorpayDelegate.linkNewUpiAccount(mobileNumber: customerMobile, result: result, eventSink: self.eventSink)
            }
        case "register":
            razorpayDelegate.register(result: result, eventSink: self.eventSink)
        case "getBankAccount":
            if let bankStr = call.arguments as? String {
                razorpayDelegate.getBankAccounts(bankStr: bankStr, result: result, eventSink: self.eventSink)
            }
        case "selectedBankAccount":
            if let bankAccountStr = call.arguments as? String {
                razorpayDelegate.selectedBankAccount(bankAccountStr: bankAccountStr, result: result, eventSink: self.eventSink)
            }
        case "getLinkedUpiAccounts":
            if let mobile = call.arguments as? String {
                razorpayDelegate.getLinkedUpiAccounts(mobileNumber: mobile, result: result, eventSink: self.eventSink)
            }
            
        case "setUpUPIPin":
            if let cardStr = call.arguments as? String {
                razorpayDelegate.setupUpiPin(cardStr: cardStr, result: result, eventSink: self.eventSink)
            }
            
        case "getBalance":
            if let upiAccountStr = call.arguments as? String {
                razorpayDelegate.getBalance(upiAccountStr: upiAccountStr, result: result, eventSink: self.eventSink)
            }
        case "changeUpiPin":
            if let upiAccountStr = call.arguments as? String {
                razorpayDelegate.changeUpiPin(upiAccountStr: upiAccountStr, result: result, eventSink: self.eventSink)
            }
        case "resetUpiPin":
            if let resetUpiAccountDict = call.arguments as? [String: Any] {
                razorpayDelegate.resetUpiPin(resetDict: resetUpiAccountDict, result: result, eventSink: self.eventSink)
                
            }
        case "delink":
            if let upiAccountStr = call.arguments as? String {
                razorpayDelegate.delink(upiAccountStr: upiAccountStr, result: result, eventSink: self.eventSink)
            }
        case "isTurboPluginAvailable":
            razorpayDelegate.isTurboPluginAvailable(result: result,eventSink: self.eventSink);
        case "linkNewUpiAccountWithUI":
            if let upiAccountStr = call.arguments as? [String: Any] {
                let customerMobile = upiAccountStr["customerMobile"] as? String ?? ""
                let color = upiAccountStr["color"] as? String ?? ""
                razorpayDelegate.linkNewUpiAccountUI(mobileNumber: customerMobile, color: color, result: result, eventSink: self.eventSink)

            }
        case "manageUpiAccounts":
            if let customerMobile = call.arguments as? String {
                razorpayDelegate.manageAccount(customerMobile: customerMobile, result: result, eventSink: self.eventSink)
            }
        case "linkNewUpiAccountTPV":
            //TODO: Implement TPV features
            break
        case "prefetchAndLinkUpiAccountsWithUI":
            if let prefetchDict = call.arguments as? [String: Any] {
                razorpayDelegate.prefetchAndLinkNewUpiAccountUI(dict: prefetchDict, result: result, eventSink: self.eventSink)
            }
        case "setPrefetchUPIPinWithUI":
            if let bankAccountStr = call.arguments as? String {
                razorpayDelegate.setPrefetchUPIPinWithUI(bankAccountStr: bankAccountStr, result: result, eventSink: self.eventSink)
            }
        default:
            print("no method")
        }
    }
}
extension SwiftRazorpayFlutterCustomuiPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        print("onListen......")
        self.eventSink = eventSink
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
