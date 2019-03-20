Pod::Spec.new do |s|
  s.name             = 'MainThreadLockChecker'
  s.version          = '0.1.2'
  s.summary          = 'MainThreadLockChecker allows to monitor main thread blocks by long-running tasks'
  s.homepage         = 'https://github.com/panda254/MainThreadLockChecker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'panda254' => 'arpitp@zendrive.com' }
  s.source           = { :git => 'https://github.com/panda254/MainThreadLockChecker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MainThreadLockChecker/Classes/**/*'
  
end
