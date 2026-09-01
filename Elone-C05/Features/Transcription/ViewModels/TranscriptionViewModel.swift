import Foundation

@MainActor
@Observable
final class TranscriptionViewModel {

    private let whisperService = WhisperService()
    private let audioManager = AudioManager()
    private let bufferConverter = BufferConverter()
    
    private var recordingTimer: Timer?
    private var lastRecordingURL: URL?

    var transcript = ""
    var isTranscribing = false
    var isRecording = false
    var recordingDuration = "00:00"
    var errorMessage: String?
    var hasRecording: Bool { lastRecordingURL != nil }
    
    func transcribeAudio() {
        guard let url = lastRecordingURL else { return }
        
        isTranscribing = true
        errorMessage = nil

        do {
            let audio = try bufferConverter.convertFile(at: url)
            transcript = whisperService.transcribe(audio: audio)
        } catch {
            errorMessage = error.localizedDescription
        }

        isTranscribing = false
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        Task {
            let granted = await audioManager.requestMicrophonePermission()
            guard granted else {
                errorMessage = "Microphone permission denied"
                return
            }
            
            do {
                try audioManager.setupAudioSession()
                try audioManager.startRecording()
                
                isRecording = true
                errorMessage = nil
                self.recordingDuration = "00:00"
                
                let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        let duration = self.audioManager.recordingDuration
                        let minutes = Int(duration) / 60
                        let seconds = Int(duration) % 60
                        self.recordingDuration = String(format: "%02d:%02d", minutes, seconds)
                    }
                }
                RunLoop.main.add(timer, forMode: .common)
                timer.fire()
                self.recordingTimer = timer
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        guard let url = audioManager.stopRecording() else {
            errorMessage = "Failed to stop recording"
            isRecording = false
            return
        }
        
        lastRecordingURL = url
        isRecording = false
        isTranscribing = true
        
        do {
            let audio = try bufferConverter.convertFile(at: url)
            transcript = whisperService.transcribe(audio: audio)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isTranscribing = false
    }

}
