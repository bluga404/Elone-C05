//
//  AudioService.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 31/08/26.
//

import Foundation
import AVFoundation

final class AudioService {

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
}
