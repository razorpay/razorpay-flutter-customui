import Flutter
import Razorpay
import WebKit

class RazorpayDelegate: NSObject {  
    
    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult) {

        let key = options["key"] as? String

        let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        let razorpay = RazorpayCheckout.initWithKey(key ?? "", andDelegate: self, withPaymentWebView: webView)
        razorpay.authorize(options)
        /* let key = options["key"] as? String
        
        let razorpay = RazorpayCheckout.initWithKey(key ?? "", andDelegateWithData: self)
        razorpay.setExternalWalletSelectionDelegate(self)
        var options = options
        options["integration"] = "flutter"
        options["FRAMEWORK"] = "flutter_customui"
        // razorpay.open(options) */
    }

}

extension RazorpayDelegate: RazorpayPaymentCompletionProtocol {
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]) {
        
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        
    }
}
