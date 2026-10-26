import Foundation

/// Fetches video metadata and direct, ad-free stream URLs from public Invidious instances.
///
/// Invidious proxies YouTube's data but serves the raw media stream without YouTube's
/// server-injected ad breaks or overlays, so no separate ad-filtering step is needed for
/// the video stream itself. In-video sponsor segments are handled separately via SponsorBlock.
public actor InvidiousService {
    /// Known-stable public instances, tried in order until one responds.
    /// A custom instance (e.g. a self-hosted one) can be prepended via `init`.
    public static let defaultInstances = [
        "https://yewtu.be",
        "https://invidious.nerdvpn.de",
        "https://inv.nadeko.net",
        "https://invidious.jing.rocks"
    ]

    private let instances: [String]
    private let session: URLSession

    public init(instances: [String] = InvidiousService.defaultInstances, session: URLSession = .shared) {
        self.instances = instances
        self.session = session
    }

    public func search(query: String) async throws -> [Video] {
        let path = "/api/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&type=video"
        return try await request(path: path)
    }

    public func trending(region: String = "VN") async throws -> [Video] {
        try await request(path: "/api/v1/trending?region=\(region)")
    }

    public func videoDetails(id: String) async throws -> VideoDetails {
        try await request(path: "/api/v1/videos/\(id)")
    }

    /// Sponsor/self-promo segments for a video, from the public SponsorBlock API.
    /// Used to auto-skip in-video sponsor ads during playback.
    public func sponsorSegments(videoId: String) async throws -> [SponsorSegment] {
        var components = URLComponents(string: "https://sponsor.ajay.app/api/skipSegments")!
        components.queryItems = [
            URLQueryItem(name: "videoID", value: videoId),
            URLQueryItem(name: "categories", value: "[\"sponsor\",\"selfpromo\",\"interaction\"]")
        ]
        guard let url = components.url else { return [] }
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
            return try JSONDecoder().decode([SponsorSegment].self, from: data)
        } catch {
            // SponsorBlock is best-effort; a failure here should never block playback.
            return []
        }
    }

    private func request<T: Decodable>(path: String) async throws -> T {
        var lastError: Error = InvidiousError.allInstancesFailed
        for instance in instances {
            guard let url = URL(string: instance + path) else { continue }
            do {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    lastError = InvidiousError.invalidResponse
                    continue
                }
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    lastError = InvidiousError.decodingFailed(error.localizedDescription)
                    continue
                }
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError
    }
}
