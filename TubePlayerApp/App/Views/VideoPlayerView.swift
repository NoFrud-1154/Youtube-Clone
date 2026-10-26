//  VideoPlayerView.swift
//  TubePlayer
//
//  Hosts an AVPlayerViewController so Picture in Picture is available, letting
//  playback continue visibly while the user switches to another app.

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let video: Video
    @State private var viewModel = PlayerViewModel()

    var body: some View {
        VStack {
            PlayerContainerView(player: viewModel.player)
                .aspectRatio(16.0 / 9.0, contentMode: .fit)

            if let details = viewModel.videoDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Text(details.title).font(.title3.bold())
                    Text(details.author).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView().padding()
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).padding()
            }

            Spacer()
        }
        .task(id: video.id) {
            await viewModel.load(video: video)
        }
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PlayerContainerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        controller.player = player
    }
}
