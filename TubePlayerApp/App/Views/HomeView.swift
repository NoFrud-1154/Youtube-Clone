//  HomeView.swift
//  TubePlayer

import SwiftUI

struct HomeView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.results) { video in
                NavigationLink(value: video) {
                    VideoRow(video: video)
                }
            }
            .navigationTitle("TubePlayer")
            .searchable(text: $viewModel.query, prompt: "Tìm video")
            .onSubmit(of: .search) {
                Task { await viewModel.search() }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Lỗi", systemImage: "wifi.exclamationmark", description: Text(error))
                }
            }
            .task {
                if viewModel.results.isEmpty {
                    await viewModel.loadTrending()
                }
            }
            .navigationDestination(for: Video.self) { video in
                VideoPlayerView(video: video)
            }
        }
    }
}

private struct VideoRow: View {
    let video: Video

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: video.thumbnailURL) { image in
                image.resizable().aspectRatio(16.0 / 9.0, contentMode: .fit)
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: 120, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title).font(.headline).lineLimit(2)
                Text(video.author).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
