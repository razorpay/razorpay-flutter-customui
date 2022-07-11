import Flutter
import Razorpay
import WebKit

class RazorpayDelegate: NSObject {  

    var pendingResult: FlutterResult!
    private var razorpay: RazorpayCheckout?
    var navController: UINavigationController?
    var webView: WKWebView?
    var parentVC = UIViewController()
    
    public func submit(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        pendingResult = result
        let key = options["key"] as? String ?? ""
        
        self.initilizeSDK(withKey: key, result: result)

        var tempOptions = options
        if let isCredPayment = tempOptions["provider"] as? String, isCredPayment == "cred" {
            tempOptions["app_present"] = 0
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
            webView?.stopLoading()
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
    
    public func initilizeSDK(withKey key: String, result: @escaping FlutterResult) {
            
        guard self.razorpay == nil else { return }
        
        pendingResult = result
        self.configureWebView()
        if let unwrappedWebView = self.webView {
            self.razorpay = RazorpayCheckout.initWithKey(key, andDelegate: self, withPaymentWebView: unwrappedWebView)
            
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
        pendingResult(response as NSDictionary)
        self.close()
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        pendingResult(response as NSDictionary)
        self.close()
    }
}
