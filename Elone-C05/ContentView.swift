//
//  ContentView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 26/08/26.
//

import SwiftUI
import whisper
import AVFoundation

struct ContentView: View {
    
    let context: OpaquePointer?
    
    let modelUrl = Bundle.main.url(
        forResource: "ggml-base",
        withExtension: "bin"
    )
    
    init() {
        print("Model:", modelUrl?.path ?? "Not found")

        if let modelUrl {
            let params = whisper_context_default_params()

            context = whisper_init_from_file_with_params(
                modelUrl.path,
                params
            )

            print(
                "Whisper context:",
                context == nil ? "FAILED" : "SUCCESS"
            )
        } else {
            context = nil
        }

        do {
            let audio = try loadAudio()

            print("Audio samples:", audio.count)
            print("First samples:", Array(audio.prefix(10)))
            
            guard let context else {
                print("Whisper context is nil")
                return
            }

            var params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)
            params.language = ("id" as NSString).utf8String
            params.translate = false
            params.print_progress = false
            params.print_realtime = false

            let result = audio.withUnsafeBufferPointer { samples in
                whisper_full(
                    context,
                    params,
                    samples.baseAddress,
                    Int32(samples.count)
                )
            }
            print("Whisper result:", result)
            
            let segmentCount = whisper_full_n_segments(context)

            for i in 0..<segmentCount {
                if let text = whisper_full_get_segment_text(context, i) {
                    print("Segment \(i):", String(cString: text))
                }
            }
            
        } catch {
            print("Audio error:", error)
        }
    }
    
    func loadAudio() throws -> [Float] {
        guard let url = Bundle.main.url(
            forResource: "Audio-001",
            withExtension: "wav"
        ) else {
            throw NSError(domain: "Audio", code: 1)
        }

        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            throw NSError(domain: "Audio", code: 2)
        }

        try audioFile.read(into: buffer)

        guard let channelData = buffer.floatChannelData else {
            throw NSError(domain: "Audio", code: 3)
        }

        return Array(
            UnsafeBufferPointer(
                start: channelData[0],
                count: Int(buffer.frameLength)
            )
        )
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Walker!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
