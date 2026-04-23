import Flutter
import Razorpay
import WebKit

class RazorpayDelegate: NSObject {  

    var pendingResult: FlutterResult!
    private var razorpay: RazorpayCheckout?
    var navController: UINavigationController?
    var webView: WKWebView?
    var parentVC = UIViewController()

    /// Scene-aware key window. `UIApplication.shared.keyWindow` is nil on iOS 13+ for many apps.
    private static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                if let w = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return w
                }
            }
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first {
                return windowScene.windows.first
            }
        }
        return UIApplication.shared.keyWindow
    }

    private static func topViewControllerForPresentation() -> UIViewController? {
        guard var vc = keyWindow()?.rootViewController else { return nil }
        while let presented = vc.presentedViewController {
            vc = presented
        }
        return vc
    }

    public func submit(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        guard self.razorpay == nil else {
            result(["error": "Payment already in progress"] as NSDictionary)
            return
        }
        pendingResult = result
        let key = options["key"] as? String ?? ""

        self.initilizeSDK(withKey: key, result: result)

        var tempOptions = options
        if let isCredPayment = tempOptions["provider"] as? String, isCredPayment == "cred" {
            tempOptions["app_present"] = 0
        }
        tempOptions["FRAMEWORK"] = "flutter"
        tempOptions.removeValue(forKey: "key")

        // `initilizeSDK` creates `navController` inside `DispatchQueue.main.async`, so
        // authorize+present must run *after* that work (and use a real window, not
        // deprecated `keyWindow` which is often nil).
        DispatchQueue.main.async { [self] in
            self.razorpay?.authorize(tempOptions)
            if let navCtrl = self.navController {
                navCtrl.modalPresentationStyle = .fullScreen
                Self.topViewControllerForPresentation()?.present(navCtrl, animated: true, completion: nil)
            }
        }
    }

    public func payWithCred(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        guard self.razorpay == nil else {
            result(["error": "Payment already in progress"] as NSDictionary)
            return
        }
        self.pendingResult = result
        let key = options["key"] as? String ?? ""
        self.initilizeSDK(withKey: key, result: result)

        var tempOptions = options
        tempOptions["app_present"] = 1
        tempOptions.removeValue(forKey: "key")

        DispatchQueue.main.async { [self] in
            if let navCtrl = self.navController {
                navCtrl.modalPresentationStyle = .fullScreen
                Self.topViewControllerForPresentation()?.present(navCtrl, animated: true, completion: nil)
            }
            self.razorpay?.payWithCred(
                withOptions: tempOptions,
                withSuccessCallback: { onSuccess in
                    self.pendingResult(onSuccess)
                },
                andFailureCallback: { onFailure in
                    self.pendingResult(onFailure)
                })
        }
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
        RazorpayCheckout.getPaymentMethods(withOptions: nil, withSuccessCallback: { successResponse in
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
        RazorpayCheckout.getSubscriptionAmount(havingSubscriptionId: subscriptionId, withSuccessCallback: { [weak self] successResponse in
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
            webView?.stopLoading()
        }

        webView = nil
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
    
    public func initilizeSDK(withKey key: String, result: @escaping FlutterResult) {

        guard self.razorpay == nil else { return }

        pendingResult = result
        self.configureWebView()
        if let unwrappedWebView = self.webView {
            // Standard init
            self.razorpay = RazorpayCheckout.initWithKey(key, andDelegate: self, withPaymentWebView: unwrappedWebView)

            // Set the amazonPlugin via setter if available
            if let rzp = self.razorpay {
                let setSelector = NSSelectorFromString("setAmazonPlugin:")
                if rzp.responds(to: setSelector) {
                    let entityClassNames = [
                        "RazorpayApayWalletPaylater.WalletPaylaterEntity",
                        "WalletPaylaterEntity",
                        "_TtC26RazorpayApayWalletPaylater20WalletPaylaterEntity",
                        "RazorpayApayWalletPaylater.AmazonWalletPaylater",
                        "AmazonWalletPaylater",
                        "_TtC26RazorpayApayWalletPaylater20AmazonWalletPaylater"
                    ]

                    for className in entityClassNames {
                        if let cls = NSClassFromString(className) as? NSObject.Type {
                            let pluginSel = NSSelectorFromString("pluginInstance")
                            if cls.responds(to: pluginSel) {
                                if let plugin = cls.perform(pluginSel)?.takeUnretainedValue() {
                                    rzp.perform(setSelector, with: plugin)
                                    break
                                }
                            }
                            let initSel = NSSelectorFromString("init")
                            if cls.responds(to: initSel) {
                                let plugin = cls.init()
                                rzp.perform(setSelector, with: plugin)
                                break
                            }
                        }
                    }
                }
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
                        try? self.razorpay?.publishUri(with: uriScheme)
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

// MARK: - Amazon Pay Link-n-Pay
extension RazorpayDelegate {

    public func amazonPayStartAuthorization(customerId: String, result: @escaping FlutterResult) {
        self.pendingResult = result

        guard let rzp = self.razorpay else {
            result(["type": "error", "data": ["code": -1, "message": "SDK not initialized"]])
            return
        }

        let pluginSelector = NSSelectorFromString("amazonPlugin")
        guard rzp.responds(to: pluginSelector),
              let amazonModule = rzp.perform(pluginSelector)?.takeUnretainedValue() as? NSObject else {
            result(["type": "error", "data": [
                "code": -2,
                "message": "amazonPlugin not set. Ensure SDK is initialized with Amazon Pay plugin."
            ]])
            return
        }

        callStartAuthorization(on: amazonModule, customerId: customerId, result: result)
    }

    private func callStartAuthorization(on module: NSObject, customerId: String, result: @escaping FlutterResult) {
        let selectors = [
            "startAuthorizationWithCustomerId:amazonAuthorizationDelegate:",
            "startAuthorization:delegate:",
            "startAuthorization:withDelegate:",
            "startAuthorizationWithCustomerId:delegate:",
        ]
        for selName in selectors {
            let sel = NSSelectorFromString(selName)
            if module.responds(to: sel) {
                module.perform(sel, with: customerId, with: self)
                return
            }
        }

        result(["type": "error", "data": [
            "code": -3,
            "message": "startAuthorization method not found on amazonPlugin"
        ]])
    }

    /// Called by native SDK when Amazon Pay linking succeeds.
    @objc func onLinkingSuccessful() {
        let reply: [String: Any] = [
            "type": "success",
            "data": ["status": "linked"]
        ]
        pendingResult?(reply)
    }

    /// Called by native SDK when Amazon Pay linking fails.
    @objc func onLinkingFailed(_ errorCode: Int, description: String) {
        let reply: [String: Any] = [
            "type": "error",
            "data": ["code": errorCode, "message": description]
        ]
        pendingResult?(reply)
    }

    /// Checks if the Amazon Pay SDK is available.
    public func isAmazonPayAvailable(result: @escaping FlutterResult) {
        let classNames = [
            "AMZNAuthorizationManager",
            "AMZNLoginManager",
            "AmazonWalletPaylater"
        ]
        for name in classNames {
            if NSClassFromString(name) != nil {
                result(true)
                return
            }
        }
        result(false)
    }
}

extension RazorpayDelegate: RazorpayPaymentCompletionProtocol {
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]) {
        pendingResult(response as NSDictionary)
        self.close()
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        pendingResult(response as NSDictionary)
        self.close()
    }
}
