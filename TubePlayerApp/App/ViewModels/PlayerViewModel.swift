//  PlayerViewModel.swift
//  TubePlayer
//
//  Wraps AVPlayer for a single video: loads the ad-free stream URL, publishes it to
//  the system's Now Playing / remote command center for background control, and
//  auto-skips SponsorBlock segments during playback.

import AVFoundation
import Combine
import MediaPlayer
import SwiftUI

@MainActor
@Observable
final class PlayerViewModel {
    let player = AVPlayer()

    private(set) var videoDetails: VideoDetails?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let service: InvidiousService
    private var sponsorSegments: [SponsorSegment] = []
    private var timeObserver: Any?

    init(service: InvidiousService = InvidiousService()) {
        self.service = service
        configureRemoteCommandCenter()
    }

    func load(video: Video) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let details = service.videoDetails(id: video.videoId)
            async let segments = service.sponsorSegments(videoId: video.videoId)
            let (resolvedDetails, resolvedSegments) = try await (details, segments)

            guard let url = resolvedDetails.playbackURL else {
                throw InvidiousError.videoUnavailable
            }

            videoDetails = resolvedDetails
            sponsorSegments = resolvedSegments
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            player.play()
            updateNowPlayingInfo()
            observeSponsorSegments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sponsor segment skipping

    /// Periodically checks playback time and jumps past any SponsorBlock segment the
    /// playhead enters, so in-video sponsor reads are skipped automatically.
    private func observeSponsorSegments() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        guard !sponsorSegments.isEmpty else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = time.seconds
            if let segment = self.sponsorSegments.first(where: { seconds >= $0.start && seconds < $0.end }) {
                self.player.seek(to: CMTime(seconds: segment.end, preferredTimescale: 600))
            }
        }
    }

    // MARK: - Background / lock-screen controls

    private func configureRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.player.play()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.player.pause()
            return .success
        }
        center.skipForwardCommand.addTarget { [weak self] _ in
            self?.seek(by: 15)
            return .success
        }
        center.skipBackwardCommand.addTarget { [weak self] _ in
            self?.seek(by: -15)
            return .success
        }
    }

    private func seek(by seconds: Double) {
        let current = player.currentTime().seconds
        player.seek(to: CMTime(seconds: current + seconds, preferredTimescale: 600))
    }

    private func updateNowPlayingInfo() {
        guard let videoDetails else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: videoDetails.title,
            MPMediaItemPropertyArtist: videoDetails.author,
            MPMediaItemPropertyPlaybackDuration: Double(videoDetails.lengthSeconds)
        ]
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
