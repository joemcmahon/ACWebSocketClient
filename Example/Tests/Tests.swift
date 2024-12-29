// https://github.com/Quick/Quick

import Testing
import Foundation
@testable import ACWebSocketClient

enum FileLoadError: Error {
    case fileNotFound
    case dataInitialisation(error: Error)
    case unexpectedContents
}

final class ACWebSocketClientParserTests {
    @Test func loadConnectData() async throws {
        guard let url = Bundle(for: ACWebSocketClientParserTests.self).url(
            forResource: "connect", withExtension: "json"
        ) else {
            throw FileLoadError.fileNotFound
        }
        print("File URL: \(url)")
        assert(FileManager.default.fileExists(atPath: url.path), "File does not exist.")
        let contents: String
        do {
            contents = try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            throw FileLoadError.dataInitialisation(error: error)
        }
        assert(!contents.isEmpty, "Loaded data should not be empty.")
        let data = Data(contents.utf8)
        let parser = ParseWebSocketData(data: data, defaultDJ: "Spud")
        let result: ACStreamStatus
        let artURL = URL(string: "https://radio2.radiospiral.net/api/station/radiospiral/art/5c1b327b6cee65132add5426-1718536022.jpg")
        do {
            result = try parser.parse(shortCode:"radiospiral")
            assert(result.artwork == artURL, "Art URL should match.")
        } catch {
            throw FileLoadError.unexpectedContents
        }
        assert(result.artwork == artURL, "artwork should match")
        assert(!result.isLiveDJ, "no live DJ")
        assert(result.dj == "Spud", "Spud set when no DJ")
        assert(result.track == "Raum 23", "right title")
        assert(result.artist == "Kontroll-Raum", "right artist")
        assert(result.album == "Check In", "right album")
     }

    @Test func loadChannelWithStreamerData() async throws {
        guard let url = Bundle(for: ACWebSocketClientParserTests.self).url(
            forResource: "channel_w_streamer", withExtension: "json"
        ) else {
            throw FileLoadError.fileNotFound
        }
        let contents: String
        do {
            contents = try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            throw FileLoadError.dataInitialisation(error: error)
        }
        assert(!contents.isEmpty, "Loaded data should not be empty.")
        let data = Data(contents.utf8)
        let parser = ParseWebSocketData(data: data, defaultDJ: "Spud")
        let result: ACStreamStatus
        let artURL = URL(string: "https://radio2.radiospiral.net/api/station/radiospiral/streamer/8/art-1731719725.jpg")
        do {
            result = try parser.parse(shortCode: "radiospiral")
        } catch {
            throw FileLoadError.unexpectedContents
        }
        assert(result.changed, "update should be true")
        assert(result.isLiveDJ, "live DJ")
        assert(result.dj == "Around the Campfire", "right DJ name")
        assert(result.track == "Thus Spake the Gypsy Witch", "right title")
        assert(result.artist == "Gypsy Witch", "right artist")
        assert(result.album == "", "right album")
        assert(result.artwork == artURL, "Art URL should match.")
    }

    @Test func loadChannelNoStreamerData() async throws {
        guard let url = Bundle(for: ACWebSocketClientParserTests.self).url(
            forResource: "channel_no_streamer", withExtension: "json"
        ) else {
            throw FileLoadError.fileNotFound
        }
        let contents: String
        do {
            contents = try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            throw FileLoadError.dataInitialisation(error: error)
        }
        assert(!contents.isEmpty, "Loaded data should not be empty.")
        let data = Data(contents.utf8)
        let parser = ParseWebSocketData(data: data, defaultDJ:"Spud the Ambient Robot")
        let result: ACStreamStatus
        let artURL = URL(string: "https://radio2.radiospiral.net/api/station/radiospiral/art/56bed7b84813058e12277412-1718534289.jpg")
        do {
            result = try parser.parse(shortCode: "radiospiral")
        } catch {
            throw FileLoadError.unexpectedContents
        }
        assert(result.changed, "update should be true")
        assert(!result.isLiveDJ, "no live DJ")
        assert(result.dj == "Spud the Ambient Robot", "Spud set when no DJ")
        assert(result.track == "Phases of the Spheres, Part 1", "right title")
        assert(result.artist == "Glenn Sogge", "right artist")
        assert(result.album == "Zodiac", "right album")
        assert(result.artwork == artURL, "Art URL should match.")
    }

    @Test func loadPingData() async throws {
        guard let url = Bundle(for: ACWebSocketClientParserTests.self).url(
            forResource: "empty", withExtension: "json"
        ) else {
            throw FileLoadError.fileNotFound
        }
        let contents: String
        do {
            contents = try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            throw FileLoadError.dataInitialisation(error: error)
        }
        assert(!contents.isEmpty, "Loaded data should not be empty.")
        let data = Data(contents.utf8)
        let parser = ParseWebSocketData(data: data, defaultDJ: "Spud")
        let result: ACStreamStatus
        do {
            result = try parser.parse(shortCode: "radiospiral")
        } catch {
            throw FileLoadError.unexpectedContents
        }
        assert(!result.changed, "ping changes nothing")
        assert(!result.isLiveDJ, "no live DJ")
        assert(result.dj == "", "right DJ name")
        assert(result.track == "", "right title")
        assert(result.artist == "", "right artist")
        assert(result.album == "", "right album")
        assert(result.artwork == nil, "Art URL should be empty")

    }
}
