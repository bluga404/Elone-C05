//
//  WhisperService.swift.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 31/08/26.
//

import Foundation
import whisper

final class WhisperService {
    
    private let context: OpaquePointer?
    
    init() {
        guard let modelURL = Bundle.main.url(
            forResource: "ggml-large-v3-turbo-q5_0",
            withExtension: "bin"
        ) else {
            print("Whisper model not found")
            context = nil
            return
        }
        
        let params = whisper_context_default_params()
        
        context = whisper_init_from_file_with_params(
            modelURL.path,
            params
        )
        
        print(
            "Whisper context:",
            context == nil ? "FAILED" : "SUCCESS"               
        )
    }
    
    func transcribe(audio: [Float]) -> String {
        guard let context else {
            return ""
        }

        var params = whisper_full_default_params(
            WHISPER_SAMPLING_GREEDY
        )

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

        guard result == 0 else {
            print("Whisper transcription failed:", result)
            return ""
        }

        let segmentCount = whisper_full_n_segments(context)

        var transcript = ""

        for i in 0..<segmentCount {
            if let text = whisper_full_get_segment_text(context, i) {
                transcript += String(cString: text)
            }
        }

        return transcript
    }
}
