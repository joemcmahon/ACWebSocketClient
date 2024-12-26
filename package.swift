// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ACWebSocketClient",
    platforms: [
           .macOS(.v10_15) // Change this from 10.13 to 10.15
    ],
    products: [
        .library(
            name: "ACWebSocketClient",
            targets: ["ACWebSocketClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ACWebSocketClient",
            dependencies: []),
        .testTarget(
            name: "ACWebSocketClientTests",
            dependencies: ["ACWebSocketClient"],
            resources: [
                .copy("channel_no_streamer.json"),
                .copy("channel_w_streamer.json"),
                .copy("connect.json"),
                .copy("empty.json")
            ])
    ]
)
