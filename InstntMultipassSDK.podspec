Pod::Spec.new do |s|
  s.name             = 'InstntMultipassSDK'
  s.version          = '1.0.0'
  s.summary          = 'Swift CocoaPod implementation of the Multipass SDK'
  s.description      = 'Swift CocoaPod implementation of the Multipass SDK'

  s.homepage         = 'https://github.com/instnt-inc/instnt-ios-sdk'  # Update with the actual homepage URL
  s.author           = { 'Instnt Inc' => 'support+github@instnt.org' }
  s.source           = { :git => 'https://github.com/instnt-inc/instnt-ios-sdk.git' }  # Specify your Git URL

  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'InstntMultipassSDK/Classes/**/*', 'InstntMultipassSDK/inc/*.h', 'InstntMultipassSDK/inc/*.swift'
  
  s.resource_bundles = {
    'MultipassSDK' => ['InstntMultipassSDK/Assets/*.xcassets']
  }
  
  s.public_header_files = 'InstntMultipassSDK/Classes/**/*.h', 'InstntMultipassSDK/inc/*.h'
  
  s.frameworks = 'UIKit'
  s.dependency 'SVProgressHUD', '~> 2.2'
  s.static_framework = true

  # Correct way to specify vendored xcframework
  s.vendored_frameworks = 'InstntMultipassSDK/vcx.xcframework'  # Update path to actual location

  # If you want to source from a remote location (e.g., GitHub release), this is how to do it:
  s.source = { 
    :http => 'https://github.com/instnt-inc/instnt-aries-vcx/releases/download/aries-framework-vcx-uniffi-ios/vcx.xcframework.zip'
  }

  # Ensure architecture exclusions are set correctly
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
