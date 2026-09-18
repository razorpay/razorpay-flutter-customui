#
# RazorpayApplePay is not published to the CocoaPods trunk. It is distributed only
# as an SPM binary target / a GitHub release asset, so CocoaPods consumers — which
# every Flutter iOS app is — have to vendor the xcframework through a local podspec.
#
# It is deliberately NOT declared as a dependency of razorpay_flutter_customui.
# Doing so would break `pod install` for every merchant using this plugin,
# including the ones who never touch Apple Pay. Merchants opt in by adding one
# line to their app's ios/Podfile:
#
#   pod 'RazorpayApplePay',
#       :podspec => '.symlinks/plugins/razorpay_flutter_customui/ios/RazorpayApplePay.podspec'
#
# Then `cd ios && pod install`. The plugin is picked up at runtime via
# NSClassFromString; when it is absent, Apple Pay reports itself unavailable and
# the rest of the SDK is unaffected.
#
Pod::Spec.new do |s|
  s.name         = 'RazorpayApplePay'
  s.version      = '2.2.0'
  s.summary      = 'Apple Pay plugin for the Razorpay Custom Checkout iOS SDK.'
  s.description  = 'Optional Apple Pay plugin, vendored for CocoaPods consumers of razorpay_flutter_customui.'
  s.license      = { :type => 'Commercial', :text => 'Copyright Razorpay' }
  s.authors      = { 'Razorpay' => 'ios@razorpay.com' }
  s.homepage     = 'https://github.com/razorpay/razorpay-customui-pod'

  s.platform     = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.source = {
    :http => 'https://github.com/razorpay/razorpay-customui-pod/releases/download/2.2.0/RazorpayApplePay.xcframework.zip'
  }
  s.vendored_frameworks = 'RazorpayApplePay.xcframework'

  # The plugin calls back into the checkout host, which owns the
  # initWithKey:andDelegate:withPaymentWebView:ApplePay: entry point.
  s.dependency 'razorpay-customui-pod', '~> 2.2.1'

  s.frameworks = 'PassKit'
end
