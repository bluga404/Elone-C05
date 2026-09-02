//
//  HomeViewModel.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    
    // Audio manager
    private let audioManager = AudioManager()
    
    // Recording List
    var recordings: [URL] = []
    
    var isRecording = false
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        do {
            try audioManager.setupAudioSession()
            try audioManager.startRecording()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        let _ = audioManager.stopRecording()
        isRecording = false
        loadRecordings()
    }
    
    func loadRecordings() {
        recordings = (try? audioManager.fetchRecordings()) ?? []
    }
    
    func playRecording(url: URL) {
        try? audioManager.play(url: url)
    }
    
    func recordingDate(_ url: URL) -> String {
        let attributes = try? FileManager.default.attributesOfItem(
            atPath: url.path
        )

        let date = attributes?[.creationDate] as? Date

        guard let date else {
            return ""
        }

        return date.formatted(
            date: .abbreviated,
            time: .shortened
        )
    }
}
