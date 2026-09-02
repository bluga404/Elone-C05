//
//  HomeViewModel.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import Foundation
import AVFoundation

@MainActor
@Observable
final class HomeViewModel {
    
    // Audio manager
    private let audioManager = AudioManager()
    // Recording List
    var recordings: [Recording] = []
    // Recording state
    var isRecording = false
    
    // Data helper function
    private func recordingDateValue(_ url: URL) -> Date {
        let attributes = try? FileManager.default.attributesOfItem(
            atPath: url.path
        )

        return attributes?[.creationDate] as? Date ?? Date()
    }
    
    // Duration helper function (async)
    private func recordingDuration(_ url: URL) async -> TimeInterval {
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            print("Failed to load duration: \(error)")
            return 0
        }
    }
    
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
        Task {
            await loadRecordings()
        }
    }
    
    func loadRecordings() async {
        let urls = (try? audioManager.fetchRecordings()) ?? []
        var newRecordings: [Recording] = []
        for url in urls {
            let duration = await recordingDuration(url)
            let recording = Recording(
                id: UUID(),
                audioURL: url,
                createdAt: recordingDateValue(url),
                duration: duration,
                transcript: nil
            )
            newRecordings.append(recording)
        }
        recordings = newRecordings

        print("=== RECORDINGS ===")
        for recording in recordings {
            print("ID:", recording.id)
            print("Audio:", recording.audioURL.lastPathComponent)
            print("Created:", recording.createdAt)
            print("Duration:", recording.duration)
            print("Transcript:", recording.transcript ?? "nil")
            print("------------------")
        }
    }
    
    func playRecording(recording: Recording) {
        print("Playing:", recording.audioURL.lastPathComponent)
        try? audioManager.play(url: recording.audioURL)
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

