#
# Be sure to run `pod lib lint ACWebSocketClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ACWebSocketClient'
  s.version          = '0.1.0'
  s.summary          = 'ACWebSocketClient provides a real-time API for Azuracast stream metadata.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Azuracast is an easy-to-use and easy-to-deploy streaming audio radio station;
simply start it up with Docker and add music to have a working station.

It does not, however, play nicely with Apple's recommended stream metadata monitoring.
Using the Apple recommendation results in no updates and empty metadata. Fortunately,
Azuracast provides high-frequency metadata updates via both a websocket interface
and an SSE one.Apple

This library connects to an Azuracast websocket server and receives and parses
the metadata into a struct, `ACStreamStatus`. At the moment (version 0.1.0),
only the track name, artist name, album name, and streamer (DJ) name are
available, but much more data is available; I intend to expand this API in the
future to add more metadata to ACStreamStatus.

To use the library, it is necessary to know the server name and the Azuracast
"shortcode" name for the station. The client is set up like this:

  var client = ACWebSocketClient(serverName: "example.com", shortcode: "station")
  client.addSubscriber(callbackFunc)
  client.connect()

The client will run in the background, calling `callbackFunc` with the
most-recently-parsed status from the websocket datastream. Your application
should extract this data and do with it what you will.

The provided example connects to the demo streaming server at azuracast.com
and displays the updates as they arrive.
                       DESC

  s.homepage         = 'https://github.com/joemcmahon/ACWebSocketClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'joemcmahon' => 'joe.mcmahon@gmail.com' }
  s.source           = { :git => 'https://github.com/joemcmahon/ACWebSocketClient.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'ACWebSocketClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ACWebSocketClient' => ['ACWebSocketClient/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
