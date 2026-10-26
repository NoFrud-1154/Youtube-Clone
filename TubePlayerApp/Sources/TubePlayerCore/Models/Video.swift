import Foundation

public struct VideoThumbnail: Codable, Hashable, Sendable {
    public let url: String
    public let width: Int
    public let height: Int
}

/// A video as listed in search results or trending feeds.
public struct Video: Codable, Hashable, Sendable, Identifiable {
    public let videoId: String
    public let title: String
    public let author: String
    public let authorId: String?
    public let lengthSeconds: Int
    public let viewCount: Int?
    public let published: Int?
    public let videoThumbnails: [VideoThumbnail]?

    public var id: String { videoId }

    public var thumbnailURL: URL? {
        videoThumbnails?.first(where: { $0.width >= 320 })
            .flatMap { URL(string: $0.url) }
            ?? videoThumbnails?.first.flatMap { URL(string: $0.url) }
    }
}

public struct VideoFormatStream: Codable, Hashable, Sendable {
    public let url: String
    public let itag: String?
    public let type: String?
    public let quality: String?
}

public struct SponsorSegment: Codable, Hashable, Sendable {
    public let category: String
    public let segment: [Double]

    public var start: Double { segment.first ?? 0 }
    public var end: Double { segment.count > 1 ? segment[1] : 0 }
}

/// Full playback details for a single video, including the direct (ad-free) stream URLs.
public struct VideoDetails: Codable, Hashable, Sendable, Identifiable {
    public let videoId: String
    public let title: String
    public let author: String
    public let description: String?
    public let lengthSeconds: Int
    public let hlsUrl: String?
    public let formatStreams: [VideoFormatStream]?
    public let adaptiveFormats: [VideoFormatStream]?

    public var id: String { videoId }

    /// Prefers the HLS master playlist (adaptive, no ad breaks) and falls back to the
    /// best progressive MP4 stream Invidious exposes.
    public var playbackURL: URL? {
        if let hlsUrl, let url = URL(string: hlsUrl) {
            return url
        }
        return formatStreams?.compactMap { URL(string: $0.url) }.first
            ?? adaptiveFormats?.compactMap { URL(string: $0.url) }.first
    }
}
