//  TubePlayerApp.swift
//  TubePlayer
//
//  App entry point. Activates the shared AVAudioSession in .playback mode so audio
//  keeps playing when the app is backgrounded or the screen locks.

import AVFoundation
import SwiftUI

@main
struct TubePlayerApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetoothA2DP])
        try? session.setActive(true)
    }
}
