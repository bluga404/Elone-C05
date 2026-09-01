import Foundation
import AVFoundation

final class BufferConverter {
    enum Error: Swift.Error {
        case failedToReadAudio
        case noChannelData
    }
    
    func convertFile(at url: URL) throws -> [Float] {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw Error.failedToReadAudio
        }
        
        try audioFile.read(into: buffer)
        
        guard let channelData = buffer.floatChannelData else {
            throw Error.noChannelData
        }
        
        return Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
    }
}
