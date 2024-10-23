import Flutter
import Razorpay
import WebKit
import TurboUpiPluginTwoP

class RazorpayDelegate: NSObject {  
    var pendingResult: FlutterResult!
    var razorpay: RazorpayCheckout?
    var navController: UINavigationController?
    var webView: WKWebView?
    var parentVC = UIViewController()
               //UPI Turbo
    var eventSink: FlutterEventSink!
    let CODE_EVENT_SUCCESS = 200
    let CODE_EVENT_ERROR = 201
    let LINK_NEW_UPI_ACCOUNT_EVENT = "linkNewUpiAccountEvent"
    let PREFETCH_AND_LINK_NEW_UPI_ACCOUNT_EVENT = "prefetchAndLinkNewUpiAccountUIEvent"

    var upiBanks:[UpiBank] = []
    var upiBankAccounts:[UpiBankAccount] = []
    var upiAccounts:[UpiAccount] = []
    var selectedBankAccount: UpiBankAccount?
    
    var isTurboUI: Bool? = true
    var merchantKey: String = ""
    
    private var  CODE_PAYMENT_ERROR = 1
    private var CODE_PAYMENT_SUCCESS = 0
    private var NETWORK_ERROR = 2
    private var INVALID_OPTIONS = 3
    private var PAYMENT_CANCELLED = 0
    private var TLS_ERROR = 6
    private var UNKNOWN_ERROR = 100

    public func submit(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        pendingResult = result
        var key = options["key"] as? String ?? ""
        if key == "" {
            let payload = options["payload"] as? [String: Any]
            key = payload?["key"] as? String ?? ""
            guard key != "" else {
                self.pendingResult(["error": "Api key cannot be empty"])
                return
            }
        }
    
        self.initilizeSDK(withKey: key, ui: self.isTurboUI, result: result)
        
        var tempOptions = options
        if let isCredPayment = tempOptions["provider"] as? String, isCredPayment == "cred" {
            tempOptions["app_present"] = 0
        }
        if tempOptions["upiAccount"] != nil {
            self.submitTurbo(tempOptions: tempOptions)
            return
        }
        tempOptions["FRAMEWORK"] = "flutter"
        tempOptions.removeValue(forKey: "key")
        self.razorpay?.authorize(tempOptions)
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        if let navCtrl = self.navController {
            navCtrl.modalPresentationStyle = .fullScreen
            rootVC?.present(navCtrl, animated: true, completion: nil)
        }
    }
    
    public func payWithCred(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        self.pendingResult = result
        let key = options["key"] as? String ?? ""
        self.initilizeSDK(withKey: key, result: result)
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        if let navCtrl = self.navController {
            navCtrl.modalPresentationStyle = .fullScreen
            rootVC?.present(navCtrl, animated: true, completion: nil)
        }
        var tempOptions = options
        tempOptions["app_present"] = 1
        tempOptions.removeValue(forKey: "key")
        
        self.razorpay?.payWithCred(withOptions: tempOptions, withSuccessCallback: { onSuccess in
            self.pendingResult(onSuccess)
        }, andFailureCallback: { onFailure in
            self.pendingResult(onFailure)
        })
    }
    
    public func changeApiKey(key: String, result: @escaping FlutterResult) {
        self.razorpay?.changeApiKey(key)
    }
    
    public func getBankLogoUrl(value: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        let bankLogo = self.razorpay?.getBankLogo(havingBankCode: value)
        self.pendingResult(bankLogo?.absoluteString)
    }
    
    public func getCardNetwork(value: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        let cardNetwork = self.razorpay?.getCardNetwork(fromCardNumber: value)
        self.pendingResult(cardNetwork)
    }
    
    public func getPaymentMethods(result: @escaping FlutterResult) {
        self.pendingResult = result
        self.razorpay?.getPaymentMethods(withOptions: nil, withSuccessCallback: { successResponse in
            self.pendingResult(successResponse  as NSDictionary)
        }, andFailureCallback: { errorResponse in
            self.pendingResult(errorResponse)
        })
    }
    
    public func getAppsWhichSupportUpi(result: @escaping FlutterResult) {
        self.pendingResult = result
        RazorpayCheckout.getAppsWhichSupportUpi(handler: { [weak self] supportedApps in
            self?.pendingResult(supportedApps)
        })
    }
    
    public func isCredAppAvailable(result: @escaping FlutterResult) {
        self.pendingResult = result
        let credURIScheme = "credpay://" // This will open CRED URL.
        if let urlString = credURIScheme.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let credURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(credURL) {
                    self.pendingResult(true)
                }
            }
        }
        self.pendingResult(false)
    }
    
    public func getSubscriptionAmount(subscriptionId: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        self.razorpay?.getSubscriptionAmount(havingSubscriptionId: subscriptionId, withSuccessCallback: { [weak self] successResponse in
            self?.pendingResult(successResponse)
        }, andFailureCallback: { [weak self] errorResponse in
            self?.pendingResult(errorResponse)
        })
    }
    
    public func getWalletLogoUrl(value: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        let walletLogoUrl = self.razorpay?.getWalletLogo(havingWalletName: value)
        pendingResult(walletLogoUrl?.absoluteString)
    }
    
    public func getCardNetworkLength(network: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        let cardNetworkLenght = self.razorpay?.getCardNetworkLength(ofNetwork: network)
        pendingResult(cardNetworkLenght)
    }
    
    public func isValidCardNumber(value: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        pendingResult(self.razorpay?.isCardValid(value))
    }
    
    public func isValidVpa(value: String, result: @escaping FlutterResult) {
        self.pendingResult = result
        self.razorpay?.isValidVpa(value, withSuccessCallback: { successResponse in
           self.pendingResult(successResponse  as NSDictionary)
        }, withFailure: { errorResponse in
            self.pendingResult(errorResponse)
        })
    }
    
    private func close() {
        razorpay?.close()
        if (self.webView != nil) {
            DispatchQueue.main.async {
                self.webView?.stopLoading()
            }
        }
        
        razorpay = nil
        
        if (self.navController != nil) {
            DispatchQueue.main.async {
                self.navController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK: Initial Setup:
extension RazorpayDelegate {
    
    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: parentVC.view.frame, configuration: configuration)
        self.webView?.navigationDelegate = self
        self.webView?.isOpaque = false
        self.webView?.backgroundColor = UIColor.white
    }
    
    public func initilizeSDK(withKey key: String, ui: Bool? = nil, result: @escaping FlutterResult) {
        guard key != "" else { return }
        guard self.razorpay == nil else { return }
        self.merchantKey = key
        self.isTurboUI = ui
        pendingResult = result
        self.configureWebView()
        
        if let unwrappedWebView = self.webView {
            if let isUi = ui, isUi == true {
                self.razorpay =  RazorpayCheckout.initWithKey(key, andDelegate: self, withPaymentWebView: unwrappedWebView, UIPlugin: RazorpayTurboUPI.UIPluginInstance())
            } else {
                self.razorpay =  RazorpayCheckout.initWithKey(key, andDelegate: self, withPaymentWebView: unwrappedWebView, plugin: RazorpayTurboUPI.pluginInstance())
            }
            
            DispatchQueue.main.async {
                let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleCancelTap(sender:)))
                
                self.parentVC.view.addSubview(unwrappedWebView)
                
                if self.parentVC.navigationController?.navigationBar != nil {
                    self.navController = self.parentVC.navigationController
                } else {
                    self.navController = UINavigationController(rootViewController: self.parentVC)
                }
                
                self.parentVC.title = "Authorize Payment"
                self.parentVC.navigationItem.leftBarButtonItem = cancelButtonItem
                
                self.parentVC.view.autoresizingMask = [.flexibleLeftMargin,
                    .flexibleRightMargin,
                    .flexibleBottomMargin,
                    .flexibleTopMargin,
                    .flexibleHeight,
                    .flexibleWidth
                ]
                
                unwrappedWebView.autoresizingMask = [.flexibleLeftMargin,
                    .flexibleRightMargin,
                    .flexibleBottomMargin,
                    .flexibleTopMargin,
                    .flexibleHeight,
                    .flexibleWidth
                ]
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleIntentCallback(_:)), name:NSNotification.Name(rawValue: "CRED_CALLBACK_NOTIFICATION"), object: nil)

    }
}

//MARK: Helper Methods:
extension RazorpayDelegate {
    
    @objc func handleIntentCallback(_ notification: NSNotification) {
            if let dict = notification.userInfo {
                if let uriScheme = dict["response"] as? String {
                    DispatchQueue.main.async {
                        self.razorpay?.publishUri(with: uriScheme)
                }
            }
        }
    }
    
    @objc
    func handleCancelTap(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Alert!", message: "Are you sure you want to cancel the transaction ?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes, Cancel", style: .destructive) { cancelAction in
            self.razorpay?.userCancelledPayment()
            self.pendingResult(["error": "Payment cancelled by user"] as NSDictionary)
            self.close()
        }
        let stayOn = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(stayOn)
        self.parentVC.present(alertController, animated: true, completion: nil)
    }
}

extension RazorpayDelegate: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.razorpay?.webView(webView, didCommit: navigation)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.razorpay?.webView(webView, didFinish: navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.razorpay?.webView(webView, didFail: navigation, withError: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.razorpay?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
}

extension RazorpayDelegate: RazorpayPaymentCompletionProtocol {
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]) {
        var reply: TurboDictionary = [
        "type": CODE_PAYMENT_SUCCESS
        ]
        var data: TurboDictionary = [
            "razorpay_payment_id": payment_id
        
        ]
        if let orderId = response["razorpay_order_id"] as? String {
            data["razorpay_order_id"] = orderId
        }
        if let subscriptionId = response["razorpay_subscription_id"] as? String {
            data["razorpay_signature"] = subscriptionId
        }
        if let signature = response["razorpay_signature"] as? String {
            data["razorpay_signature"] = signature
        }
        
        reply["data"] = data
        sendReply(data: reply)
        self.close()
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        var reply: TurboDictionary = [
        "type": CODE_PAYMENT_ERROR
        ]
        let data: TurboDictionary = [
        "code": code,
         "message": str
        ]
        reply["data"] = data
        sendReply(data: reply)
        self.close()
    }
}
