#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint razorpay_flutter_customui.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'razorpay_flutter_customui'
  s.version          = '1.2.1'
  s.summary          = 'Flutter plugin for Razorpay Custom SDK.'
  s.description      =  'Flutter plugin for Razorpay Custom SDK.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Razorpay' => 'ramprasad.a@razorpay.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  s.vendored_frameworks = 'Frameworks/Razorpay.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'


end
