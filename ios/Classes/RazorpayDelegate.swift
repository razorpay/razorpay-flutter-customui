import Flutter
import Razorpay
import WebKit

class RazorpayDelegate: NSObject {  

    private var pendingResult: FlutterResult!
    private var razorpay: RazorpayCheckout?
    var navController: UINavigationController?
    var webView: WKWebView?
    let parentVC = UIViewController()
    
    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        pendingResult = result
        let key = options["key"] as? String
        
        DispatchQueue.main.async {
            let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleCancelTap(sender:)))
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            
            self.configureWebView()
            if let unwrappedWebView = self.webView {
                self.parentVC.view.addSubview(unwrappedWebView)
                
                if self.parentVC.navigationController?.navigationBar != nil {
                    self.navController = rootVC?.navigationController
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
                
                self.razorpay = RazorpayCheckout.initWithKey(key ?? "", andDelegate: self, withPaymentWebView: unwrappedWebView)
                var tempOptions = options
                tempOptions.removeValue(forKey: "key")
                if let navCtrl = self.navController {
                    rootVC?.present(navCtrl, animated: true, completion: nil)
                }
                self.razorpay?.authorize(tempOptions)
            }
        }
    }
    
    public func changeApiKey(key: String) {
        self.razorpay?.changeApiKey(key)
    }
    
    public func getBankLogoUrl(value: String) {
        let bankLogo = self.razorpay?.getBankLogo(havingBankCode: value)
        self.pendingResult(bankLogo)
    }
    
    public func getCardNetwork(value: String) {
        let cardNetwork = self.razorpay?.getCardNetwork(fromCardNumber: value)
        self.pendingResult(cardNetwork)
    }
    
    public func getPaymentMethods(options: Dictionary<String, Any>) {
        self.razorpay?.getPaymentMethods(withOptions: options, withSuccessCallback: { [weak self] successResponse in
            self?.pendingResult(successResponse)
        }, andFailureCallback: { [weak self] errorResponse in
            self?.pendingResult(errorResponse)
        })
    }
    
    public func getAppsWhichSupportUpi() {
        RazorpayCheckout.getAppsWhichSupportUpi(handler: { [weak self] supportedApps in
            self?.pendingResult(supportedApps)
        })
    }
    public func getSubscriptionAmount(options: Dictionary<String, Any>) {
        self.razorpay?.getSubscriptionAmount(options: options, withSuccessCallback: { [weak self] successResponse in
            self?.pendingResult(successResponse)
        }, andFailureCallback: { [weak self] errorResponse in
            self?.pendingResult(errorResponse)
        })
    }
    
    public func getWalletLogoUrl(value: String) {
        let walletLogoUrl = self.razorpay?.getWalletLogo(havingWalletName: value)
        pendingResult(walletLogoUrl)
    }
    
    public func isValidCardNumber(value: String) {
        pendingResult(self.razorpay?.isCardValid(value))
    }
    
    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: parentVC.view.frame, configuration: configuration)
        self.webView?.navigationDelegate = self
        self.webView?.isOpaque = false
        self.webView?.backgroundColor = UIColor.white   
    }
    
    @objc
    func handleCancelTap(sender: UIBarButtonItem) {
        
        razorpay?.userCancelledPayment()
        razorpay?.close()
        self.close()
        navController?.dismiss(animated: true, completion: nil)
    }
    
    private func close() {
        if (self.webView != nil) {
            webView?.stopLoading()
        }
        
        if (self.navController != nil) {
            self.navController?.dismiss(animated: true, completion: nil)
        }
        
        razorpay = nil
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
        print(payment_id)
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        print(response)
    }
}
