import Foundation
import AVFoundation

final class AudioManager {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private(set) var isRecording = false
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var recordingURL: URL?
    
    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    // MARK: - Directory
    private func audioDirectory() throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = documents.appendingPathComponent(
            "Audio",
            isDirectory: true
        )

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }

        return directory
    }
    
    // MARK: - Recording
    
    func startRecording() throws {
        let filename = "recording_\(UUID().uuidString).wav"
        let url = try audioDirectory().appendingPathComponent(filename)
        recordingURL = url
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        
        recordingDuration = 0
        isRecording = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.audioRecorder, recorder.isRecording else { return }
            self.recordingDuration = recorder.currentTime
        }
    }
    
    func stopRecording() -> URL? {
        timer?.invalidate()
        timer = nil
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        isRecording = false
        
        return recordingURL
    }
    
    // MARK: - Fetch Recordings

    func fetchRecordings() throws -> [URL] {
        let directory = try audioDirectory()

        return try FileManager.default
            .contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [
                    .creationDateKey,
                    .fileSizeKey
                ]
            )
            .filter {
                $0.pathExtension.lowercased() == "wav"
            }
            .sorted {
                $0.lastPathComponent > $1.lastPathComponent
            }
    }

    // MARK: - Playback

    func play(url: URL) throws {
        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .playback,
            mode: .default
        )

        try audioSession.setActive(true)

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Delete

    func delete(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
