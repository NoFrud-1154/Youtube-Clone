import XCTest
@testable import TubePlayerCore

final class VideoDetailsTests: XCTestCase {
    func testPlaybackURLPrefersHLS() {
        let details = VideoDetails(
            videoId: "abc123",
            title: "Test",
            author: "Author",
            description: nil,
            lengthSeconds: 120,
            hlsUrl: "https://example.com/master.m3u8",
            formatStreams: [VideoFormatStream(url: "https://example.com/fallback.mp4", itag: "18", type: "video/mp4", quality: "360p")],
            adaptiveFormats: nil
        )
        XCTAssertEqual(details.playbackURL?.absoluteString, "https://example.com/master.m3u8")
    }

    func testPlaybackURLFallsBackToFormatStream() {
        let details = VideoDetails(
            videoId: "abc123",
            title: "Test",
            author: "Author",
            description: nil,
            lengthSeconds: 120,
            hlsUrl: nil,
            formatStreams: [VideoFormatStream(url: "https://example.com/fallback.mp4", itag: "18", type: "video/mp4", quality: "360p")],
            adaptiveFormats: nil
        )
        XCTAssertEqual(details.playbackURL?.absoluteString, "https://example.com/fallback.mp4")
    }

    func testSponsorSegmentStartEnd() {
        let segment = SponsorSegment(category: "sponsor", segment: [10.5, 42.0])
        XCTAssertEqual(segment.start, 10.5)
        XCTAssertEqual(segment.end, 42.0)
    }
}
