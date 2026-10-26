//  SearchViewModel.swift
//  TubePlayer

import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
    var query = ""
    private(set) var results: [Video] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let service: InvidiousService

    init(service: InvidiousService = InvidiousService()) {
        self.service = service
    }

    func loadTrending() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            results = try await service.trending()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            results = try await service.search(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
