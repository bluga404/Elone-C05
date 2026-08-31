//
//  TranscriptionViewModel.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 31/08/26.
//

import Foundation

@Observable
final class TranscriptionViewModel {

    private let audioService = AudioService()
    private let whisperService = WhisperService()

    var transcript = ""
    var isTranscribing = false
    var errorMessage: String?
    
    func transcribeAudio() {
        isTranscribing = true
        errorMessage = nil

        print("Starting transcription...")

        do {
            let audio = try audioService.loadAudio()
            print("Audio loaded:", audio.count)

            transcript = whisperService.transcribe(audio: audio)
            print("Transcript:", transcript)

        } catch {
            errorMessage = error.localizedDescription
            print("Transcription error:", error)
        }

        isTranscribing = false
    }

}
