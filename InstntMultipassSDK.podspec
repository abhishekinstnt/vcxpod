#
# Be sure to run `pod lib lint MultipassSDK' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InstntMultipassSDK'
  s.version          = '1.0.0'
  s.summary          = 'Swift CocoaPod implementation of the Multipass SDK'
  s.description      = 'Swift CocoaPod implementation of the Multipass SDK'

  s.homepage         = 'test' #'https://github.com/instnt-inc/instnt-ios-sdk'
  s.author           = { 'Instnt Inc' => 'support+github@instnt.org' }
  s.source           = { :git => '' }
  
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'InstntMultipassSDK/Classes/**/*', 'InstntMultipassSDK/inc/*.h', 'InstntMultipassSDK/inc/*.swift'
  
  s.resource_bundles = {
     'MultipassSDK' => ['InstntMultipassSDK/Assets/*.xcassets']
  }
  s.public_header_files = 'Pod/Classes/**/*.h', 'MultipassSDK/inc/*.h'
  
  s.frameworks = 'UIKit'
  s.dependency 'ActionSheetPicker-3.0', '~> 2.7'
  s.dependency 'IQKeyboardManagerSwift', '~> 6.5'
  s.dependency 'SVProgressHUD', '~> 2.2'
  s.static_framework = true
  
    #s.vendored_frameworks =  'InstntMultipassSDK/vcx.xcframework'

# Point to the URL of the zipped xcframework
  s.source = { 
    :http => 'https://github.com/instnt-inc/instnt-aries-vcx/releases/download/aries-framework-vcx-uniffi-ios/vcx.xcframework.zip'
  }
  
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
