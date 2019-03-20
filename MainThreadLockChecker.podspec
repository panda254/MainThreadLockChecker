#
# Be sure to run `pod lib lint MainThreadLockChecker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MainThreadLockChecker'
  s.version          = '0.1.0'
  s.summary          = 'MainThreadLockChecker allows to monitor main thread blocks by long-running tasks'
  s.homepage         = 'https://github.com/panda254/MainThreadLockChecker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'panda254' => 'arpitp@zendrive.com' }
  s.source           = { :git => 'https://github.com/panda254/MainThreadLockChecker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MainThreadLockChecker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MainThreadLockChecker' => ['MainThreadLockChecker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
