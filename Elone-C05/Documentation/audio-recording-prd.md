# Audio Recording Feature - Implementation Guide

## Overview
Add microphone recording to Elone: record audio → save to temp file → transcribe with Whisper.

## Implementation Tasks

### Phase 1: AudioManager
**File:** `Services/Audio/AudioManager.swift`

- [ ] Create `AudioManager` class with `AVAudioRecorder` and `Timer`
- [ ] Properties: `isRecording`, `recordingDuration`, `recordingURL`
- [ ] Implement `setupAudioSession()` - configure for recording
- [ ] Implement `requestMicrophonePermission() async -> Bool`
- [ ] Implement `startRecording() throws` - create temp WAV (16kHz mono PCM), start recorder and timer
- [ ] Implement `stopRecording() -> URL?` - stop recorder, return file URL

**Settings:** 16kHz, mono, 16-bit PCM, Linear PCM format

---

### Phase 2: BufferConverter
**File:** `Services/Audio/BufferConverter.swift`

- [ ] Create `BufferConverter` class with error enum
- [ ] Implement `convertFile(at url: URL) throws -> [Float]`
  - Load WAV with `AVAudioFile`
  - Read into buffer, extract mono channel as Float array

---

### Phase 3: ViewModel Updates
**File:** `Features/Transcription/ViewModels/TranscriptionViewModel.swift`

- [ ] Add `@MainActor` annotation
- [ ] Add properties: `audioManager`, `bufferConverter`, `isRecording`, `recordingDuration` (mm:ss format)
- [ ] Implement `toggleRecording()` - start or stop based on state
- [ ] Implement `startRecording()` - request permission, setup session, start recording, start UI timer
- [ ] Implement `stopRecording()` - stop recording, convert audio, transcribe, update transcript
- [ ] Keep existing `transcribeAudio()` for bundled files

---

### Phase 4: UI Updates
**File:** `Features/Transcription/Views/TranscriptionView.swift`

- [ ] Add circular record/stop button (80pt)
  - Idle: `mic.circle.fill`, blue
  - Recording: `stop.circle.fill`, red
- [ ] Add recording duration display (mm:ss) with pulsing red dot
- [ ] Add progress indicator during transcription
- [ ] Update transcript display area
- [ ] Optionally keep "Transcribe Audio" button for bundled files

**Layout:**
```
Title
Record Button (80pt circle)
Duration (when recording)
ProgressView (when transcribing)
Transcript Section
```

---

## Data Flow

```
Record Tap → toggleRecording() → startRecording()
  → Permission + Setup → AVAudioRecorder → temp file
  → UI timer updates duration

Stop Tap → toggleRecording() → stopRecording()
  → Get file URL → BufferConverter → [Float]
  → WhisperService → transcript
  → Update UI
```

---

## Technical Specs

**Audio Format:** 16kHz, mono, 16-bit PCM, .wav  
**Temp Location:** `FileManager.default.temporaryDirectory`  
**Filename:** `recording_<UUID>.wav`

**Duration Format:**
```swift
String(format: "%02d:%02d", minutes, seconds)
```

---

## Acceptance Criteria

- [ ] Record button toggles between blue mic and red stop icons
- [ ] Duration displays during recording (mm:ss)
- [ ] Pulsing red dot shows during recording
- [ ] Stop triggers transcription with progress indicator
- [ ] Transcript appears after transcription completes
- [ ] Existing bundled file transcription still works
- [ ] Microphone permission requested and handled gracefully
- [ ] Errors display appropriate messages

---

## Error Handling

- Permission denied → error message, don't start
- Recording fails → error message, reset UI
- Conversion/transcription fails → error message, keep transcript empty
