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
    
    // Transcription Services
    private let whisperService = WhisperService()
    private let bufferConverter = BufferConverter()
    
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
        print("=== TOGGLE RECORDING ===")
        print("isRecording:", isRecording)

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
        print("=== STOP RECORDING ===")

        guard let url = audioManager.stopRecording() else {
            print("Failed to stop recording")
            isRecording = false
            return
        }

        print("Stopped:", url.lastPathComponent)

        isRecording = false

        Task {
            print("=== LOAD RECORDINGS AFTER STOP ===")

            await loadRecordings()

            print("=== FINDING RECORDING ===")

            guard let recording = recordings.first(where: {
                $0.audioURL.lastPathComponent == url.lastPathComponent
            }) else {
                print("Recording not found")
                return
            }

            print("Found:", recording.audioURL.lastPathComponent)

            transcribe(recording: recording)
        }
    }
    
    func loadRecordings() async {
        let urls = (try? audioManager.fetchRecordings()) ?? []
        var newRecordings: [Recording] = []

        for url in urls {
            let duration = await recordingDuration(url)

            if let existingRecording = recordings.first(where: {
                $0.audioURL.lastPathComponent == url.lastPathComponent
            }) {
                newRecordings.append(
                    Recording(
                        id: existingRecording.id,
                        audioURL: url,
                        createdAt: existingRecording.createdAt,
                        duration: duration,
                        transcript: existingRecording.transcript
                    )
                )
            } else {
                newRecordings.append(
                    Recording(
                        id: UUID(),
                        audioURL: url,
                        createdAt: recordingDateValue(url),
                        duration: duration,
                        transcript: nil
                    )
                )
            }
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
    
    func transcribe(recording: Recording) {
        print("=== TRANSCRIBING ===")
        print("Audio:", recording.audioURL.lastPathComponent)

        do {
            let audio = try bufferConverter.convertFile(at: recording.audioURL)

            print("Audio converted successfully")

            let transcript = whisperService.transcribe(audio: audio)

            print("Transcript result:", transcript)

            if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                recordings[index].transcript = transcript

                print("Transcript saved to recording")
            } else {
                print("Recording not found in recordings array")
            }
        } catch {
            print("Failed to transcribe:", error)
        }
    }
}

