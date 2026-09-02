import Flutter
import PassKit
import Razorpay
import WebKit

class RazorpayDelegate: NSObject {  

    var pendingResult: FlutterResult!
    private var razorpay: RazorpayCheckout?
    private var isPaymentInProgress = false
    var navController: UINavigationController?
    var webView: WKWebView?
    var parentVC = UIViewController()

    // Separate result for Amazon Pay linking — avoids race conditions with
    // the shared pendingResult which can be overwritten by concurrent utility calls.
    var amazonPayResult: FlutterResult?

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
        guard !isPaymentInProgress else {
            result(["error": "Payment already in progress"] as NSDictionary)
            return
        }
        isPaymentInProgress = true
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
        guard !isPaymentInProgress else {
            result(["error": "Payment already in progress"] as NSDictionary)
            return
        }
        isPaymentInProgress = true
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
                    self.isPaymentInProgress = false
                },
                andFailureCallback: { onFailure in
                    self.pendingResult(onFailure)
                    self.isPaymentInProgress = false
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
    
    public func getRecommendedInstruments(options: [String: Any], result: @escaping FlutterResult) {
        self.pendingResult = result
        RazorpayCheckout.getRecommendedInstruments(withOptions: options, withSuccessCallback: { successResponse in
            self.pendingResult(successResponse as NSDictionary)
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
        isPaymentInProgress = false
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
            self.razorpay = RazorpayCheckout.initWithKey(key, andDelegate: self, withPaymentWebView: unwrappedWebView)

            // Attach Amazon Pay plugin via the wrapper's `amazonPlugin` property.
            // `amazonPlugin` is on Razorpay.RazorpayCheckout (the wrapper layer imported here);
            // `amazonPay` is on the inner RazorpayCustom layer and is not accessible here.
            // WalletPaylaterEntity is instantiated directly — AmazonWalletPaylater.pluginInstance()
            // is non-@objc and cannot be called via perform().
            if let rzp = self.razorpay {
                let entityClassName = "RazorpayApayWalletPaylater.WalletPaylaterEntity"
                let setAmazonPluginSel = NSSelectorFromString("setAmazonPlugin:")
                if let entityCls = NSClassFromString(entityClassName) as? NSObject.Type,
                   rzp.responds(to: setAmazonPluginSel) {
                    let entity = entityCls.init()
                    // Must call initiate(key_id:) before setting the plugin —
                    // this mirrors what RazorpayCheckout.initWithKey(...AmazonpayPlugin:) does
                    // internally. Without it, key_id is nil and Razorpay's backend returns
                    // "Required fields in state missing" after Amazon authorization.
                    let initiateSel = NSSelectorFromString("initiateWithKey_id:")
                    if entity.responds(to: initiateSel) {
                        entity.perform(initiateSel, with: key)
                    }
                    rzp.perform(setAmazonPluginSel, with: entity)
                }
            }

            // Attach the Apple Pay plugin (same runtime mechanism as Amazon Pay above).
            // The merchant-facing factory is the API-Council-approved
            // ApplePay.pluginInstance() (module RazorpayApplePay). We do NOT call it here
            // reflectively: like Amazon's pluginInstance(), a Swift static is not exposed
            // to the Obj-C runtime, and this module does not import RazorpayApplePay. So
            // internally we instantiate the plugin's concrete conformer and call
            // initiate(key_id:) before setApplePay:, mirroring the Amazon slice.
            //
            // DECISION FOR THE SDK TEAM (see PR thread):
            //  (a) native/preferred: import RazorpayApplePay in this plugin and use the
            //      typed init RazorpayCheckout.initWithKey(..., ApplePay: ApplePay.pluginInstance())
            //      — compiler-checked, uses the council factory literally, no reflection.
            //      Requires the Flutter distribution to vend RazorpayApplePay (2.2.0 is
            //      SPM-only today, so this needs the packaging call first).
            //  (b) reflection (below): works with the existing CocoaPods dependency, no
            //      hard module import; needs the concrete conformer + selectors confirmed.
            // TODO(verify): concrete conformer class name + setApplePay:/initiateWithKey_id:
            //   against RazorpayApplePay 2.2.0.
            if let rzp = self.razorpay {
                let pluginClassName = "RazorpayApplePay.ApplePayEntity" // TODO(verify) conformer
                let setApplePaySel = NSSelectorFromString("setApplePay:")
                if let pluginCls = NSClassFromString(pluginClassName) as? NSObject.Type,
                   rzp.responds(to: setApplePaySel) {
                    let plugin = pluginCls.init()
                    let initiateSel = NSSelectorFromString("initiateWithKey_id:")
                    if plugin.responds(to: initiateSel) {
                        plugin.perform(initiateSel, with: key)
                    }
                    rzp.perform(setApplePaySel, with: plugin)
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
                        do {
                            try self.razorpay?.publishUri(with: uriScheme)
                        } catch {
                            // Non-fatal: log so failures are visible during debugging.
                            NSLog("[RazorpayFlutter] publishUri failed for UPI intent callback: %@", error.localizedDescription)
                        }
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
        pendingResult(response as NSDictionary)
        self.close()
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        pendingResult(response as NSDictionary)
        self.close()
    }
}

// MARK: - Amazon Pay Link-n-Pay
extension RazorpayDelegate {

    public func amazonPayStartAuthorization(customerId: String, result: @escaping FlutterResult) {
        // Store in dedicated property — NOT pendingResult — to avoid race conditions
        // with concurrent utility calls (getPaymentMethods, isValidVpa, etc.)
        guard let rzp = self.razorpay else {
            result(["type": "error", "data": ["code": -1, "message": "SDK not initialized. Call initilizeSDK first."]])
            return
        }

        let pluginSelector = NSSelectorFromString("amazonPlugin")
        guard rzp.responds(to: pluginSelector),
              let amazonModule = rzp.perform(pluginSelector)?.takeUnretainedValue() as? NSObject else {
            result(["type": "error", "data": [
                "code": -2,
                "message": "Amazon Pay plugin not available. Add razorpay-apay-wallet-paylater pod."
            ]])
            return
        }

        self.amazonPayResult = result

        let sel = NSSelectorFromString("startAuthorizationWithCustomerId:amazonAuthorizationDelegate:")
        if amazonModule.responds(to: sel) {
            amazonModule.perform(sel, with: customerId, with: self)
        } else {
            result(["type": "error", "data": [
                "code": -3,
                "message": "startAuthorizationWithCustomerId:amazonAuthorizationDelegate: not found"
            ]])
            self.amazonPayResult = nil
        }
    }

    /// AmazonAuthorizationDelegate — called on linking success.
    /// Matches: func onLinkingSuccessful() in RazorpayPublicProtocols.swift
    /// `dynamic` ensures the selector is always registered in the ObjC runtime.
    @objc dynamic func onLinkingSuccessful() {
        let reply: [String: Any] = [
            "type": "success",
            "data": ["status": "linked"]
        ]
        amazonPayResult?(reply)
        amazonPayResult = nil
    }

    /// AmazonAuthorizationDelegate — called on linking failure.
    /// Matches: func onLinkingFailed(_ code: String, description: String) in RazorpayPublicProtocols.swift
    @objc dynamic func onLinkingFailed(_ code: String, description: String) {
        let reply: [String: Any] = [
            "type": "error",
            "data": ["code": code, "message": description]
        ]
        amazonPayResult?(reply)
        amazonPayResult = nil
    }

    public func isAmazonPayAvailable(result: @escaping FlutterResult) {
        guard let rzp = self.razorpay else {
            result(false)
            return
        }
        let pluginSelector = NSSelectorFromString("amazonPlugin")
        if rzp.responds(to: pluginSelector),
           let plugin = rzp.perform(pluginSelector)?.takeUnretainedValue() {
            result(plugin is NSObject)
        } else {
            result(false)
        }
    }

    // MARK: - Apple Pay

    /// Device capability for Apple Pay via PassKit (device + Wallet). Matches the
    /// React Native wrapper and the native ApplePay.isApplePaySupported() gate.
    /// This is a real eligibility check (not merely "is the plugin attached"),
    /// so the merchant only shows the Apple Pay button when a payment can be made.
    public func isApplePayAvailable(result: @escaping FlutterResult) {
        result(PKPaymentAuthorizationController.canMakePayments())
    }
}
