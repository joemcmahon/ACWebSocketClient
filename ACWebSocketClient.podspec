Pod::Spec.new do |s|
  s.name             = 'ACWebSocketClient'
  s.version          = '0.1.0'
  s.summary          = 'A websocket client for Azuracast now-playing metadata'
  s.description      = 'This library creates a websocket client that monitors an Azuracast streaming radio station and dynamically calls back to update track information.'
  s.homepage         = 'https://github.com/username/ACWebSocketClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'joe.mcmahon@gmail.com' }
  s.source           = { :git => 'https://github.com/joemcmahon/ACWebSocketClient.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'ACWebSocketClient/**/*'
end
