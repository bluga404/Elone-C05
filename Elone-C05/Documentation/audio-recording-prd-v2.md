# Audio Recording Feature v2 - Bug Fixes and Improvements

## Overview
Fix issues identified in v1: timer starting from ~4 instead of 0, auto-detect language for Whisper transcription, and make the transcribe button work with the last recording.

---

## Issues to Fix

### 1. Timer Starts from ~4 Instead of 0
**Problem:** When pressing the record button, the duration display shows ~4 seconds instead of starting from 00:00.

**Root Cause:** The UI timer is created inside an async `Task` after permission request and audio session setup. `Timer.scheduledTimer` may not attach to the main run loop properly in this context, causing delayed first tick. By the time it fires, `recorder.currentTime` has already accumulated several seconds.

**Fix:**
- Create the timer on `RunLoop.main` with `.common` mode
- Fire the timer immediately with `timer.fire()` for an instant first update
- Reset `recordingDuration` to `"00:00"` before creating the timer

**File:** `Features/Transcription/ViewModels/TranscriptionViewModel.swift`

```swift
recordingDuration = "00:00"
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
recordingTimer = timer
```

---

### 2. Auto-Detect Language for Whisper
**Problem:** Whisper only detects Indonesian ("id"). English and other languages are not recognized.

**Root Cause:** Language is hardcoded to `"id"` in `WhisperService.swift:47`.

**Fix:** Change language to `"auto"` so Whisper auto-detects the spoken language.

**File:** `Services/Whisper/WhisperService.swift`

```swift
params.language = ("auto" as NSString).utf8String
```

---

### 3. Transcribe Button Uses Last Recording
**Problem:** The "Transcribe Audio" button transcribes a bundled audio file instead of the user's last recording. Auto-transcription after recording works, but the button should also work with the recorded audio.

**Root Cause:** `transcribeAudio()` calls `audioService.loadAudio()` which loads a bundled WAV file.

**Fix:**
- Store the last recording URL in the ViewModel
- Update `transcribeAudio()` to transcribe the last recording
- Disable the button when no recording exists yet
- Remove unused `audioService` dependency

**Files:**
- `Features/Transcription/ViewModels/TranscriptionViewModel.swift`
- `Features/Transcription/Views/TranscriptionView.swift`

---

## Implementation Tasks

### Task 1: Fix Timer
**File:** `TranscriptionViewModel.swift`

- [ ] Reset `recordingDuration = "00:00"` before timer creation
- [ ] Create timer with `Timer(timeInterval:repeats:block:)` instead of `scheduledTimer`
- [ ] Add timer to `RunLoop.main` with `.common` mode
- [ ] Call `timer.fire()` immediately

### Task 2: Auto-Detect Language
**File:** `WhisperService.swift`

- [ ] Change `params.language` from `"id"` to `"auto"`

### Task 3: Transcribe Last Recording
**Files:** `TranscriptionViewModel.swift`, `TranscriptionView.swift`

- [ ] Add `lastRecordingURL: URL?` property to ViewModel
- [ ] Store recording URL in `stopRecording()`
- [ ] Update `transcribeAudio()` to use `lastRecordingURL` with `bufferConverter`
- [ ] Remove `audioService` property
- [ ] Disable "Transcribe Audio" button when `lastRecordingURL` is nil

---

## Data Flow (Updated)

```
Record Tap → toggleRecording() → startRecording()
  → Permission + Setup → AVAudioRecorder → temp file
  → UI timer (RunLoop.main + .common) updates duration from 00:00

Stop Tap → toggleRecording() → stopRecording()
  → Store recording URL
  → Get file URL → BufferConverter → [Float]
  → WhisperService (auto-detect language) → transcript
  → Update UI

Transcribe Button → transcribeAudio()
  → Use lastRecordingURL → BufferConverter → [Float]
  → WhisperService → transcript
  → Update UI
```

---

## Acceptance Criteria

- [ ] Timer displays 00:00 immediately when recording starts
- [ ] Timer increments correctly (00:01, 00:02, ...)
- [ ] Whisper auto-detects Indonesian, English, and other languages
- [ ] "Transcribe Audio" button transcribes the last recording
- [ ] Button is disabled when no recording has been made yet
- [ ] Auto-transcription after recording still works
