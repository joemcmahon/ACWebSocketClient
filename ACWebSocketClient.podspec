Pod::Spec.new do |s|
  s.name             = 'ACWebSocketClient'
  s.version          = '0.1.9'
  s.summary          = 'ACWebSocketClient provides a real-time API for Azuracast stream metadata.'

  s.description      = <<-DESC
Azuracast is an easy-to-use and easy-to-deploy streaming audio radio station;
simply start it up with Docker and add music to have a working station.

It does not, however, play nicely with Apple's recommended stream metadata monitoring.
Using the Apple recommendation results in no updates and empty metadata. Fortunately,
Azuracast provides high-frequency metadata updates via both a websocket interface
and an SSE one.

This library connects to an Azuracast websocket server and receives and parses
the metadata into a struct, `ACStreamStatus`. For 0.1.x releases,
only the track name, artist name, album name, and streamer (DJ) name are
available, but much more data is available; I intend to expand this API in the
future to add more metadata to `ACStreamStatus`.

To use the library, it is necessary to know the server name and the Azuracast
"shortcode" name for the station. These can be obtained from the station's
profile page. Be especially careful to get the shortcode right, or the
client will connect but not be able to fetch metadata. The client is set up like this:

  // Initialize the client with a server and shortcode
  var client = ACWebSocketClient(serverName: "example.com", shortcode: "station")

  // This function sets accesses the data in the ACStreamStatus struct for
  // use by main application.
  client.addSubscriber(callbackFunc)

  // Actually connect the client and receive data asynchronously.
  client.connect()

The client will run in the background, calling `callbackFunc` with the
most-recently-parsed status from the websocket datastream, returning it as
an `ACStreamStatus` struct. Your application should extract this data
and do with it what you will.

The provided example applications (iOS, Mac, and tvOS) connect to the
demo streaming server at azuracast.com and displays the updates as they
arrive.
                       DESC

  s.homepage         = 'https://github.com/joemcmahon/ACWebSocketClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'joemcmahon' => 'joe.mcmahon@gmail.com' }
  s.source           = { :git => 'https://github.com/joemcmahon/ACWebSocketClient.git', :tag => s.version.to_s }
  s.social_media_url = 'https://bsky.app/profile/equinoxdeschanel.bsky.social'

  s.ios.deployment_target = '13.0'
  s.macos.deployment_target = '10.15'
  s.tvos.deployment_target = '15'
  s.swift_versions = '5.0'

  s.source_files = 'Sources/**/*'
end
