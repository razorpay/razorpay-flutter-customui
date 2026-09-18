#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint razorpay_flutter_customui.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'razorpay_flutter_customui'
  s.version          = '1.3.2'
  s.summary          = 'Flutter plugin for Razorpay Custom SDK.'
  s.description      =  'Flutter plugin for Razorpay Custom SDK.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Razorpay' => 'support@razorpay.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # s.vendored_frameworks = 'Frameworks/Razorpay.xcframework'
  # Apple Pay needs the 2.2.x checkout host: the
  # initWithKey:andDelegate:withPaymentWebView:ApplePay: entry point and the
  # Apple Pay analytics sink only exist there.
  s.dependency 'razorpay-customui-pod', '~> 2.2.3'

  # PassKit is a system framework and always available. The Apple Pay sheet itself
  # lives in the RazorpayApplePay plugin, which declares PassKit too; this stays
  # here so a consuming app links it regardless of plugin load order.
  #
  # RazorpayApplePay is intentionally NOT a dependency here — it is not on the
  # CocoaPods trunk, so declaring it would break `pod install` for every merchant
  # using this plugin. Merchants opt in via ios/RazorpayApplePay.podspec; see the
  # Apple Pay section of README.md.
  s.frameworks = 'PassKit'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'


end
