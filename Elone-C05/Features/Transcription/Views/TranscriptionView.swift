import SwiftUI

struct TranscriptionView: View {

    @State private var viewModel = TranscriptionViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Transcription")
                .font(.largeTitle)
                .bold()

            Button {
                viewModel.toggleRecording()
            } label: {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isRecording ? .red : .blue)
            }
            .disabled(viewModel.isTranscribing)
            
            if viewModel.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(), value: viewModel.isRecording)
                    
                    Text(viewModel.recordingDuration)
                        .font(.title2)
                        .fontDesign(.monospaced)
                        .foregroundColor(.red)
                }
            }
            
            if viewModel.isTranscribing {
                ProgressView("Transcribing...")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Transcript")
                    .font(.headline)

                ScrollView {
                    Text(
                        viewModel.transcript.isEmpty
                        ? "Your transcript will appear here."
                        : viewModel.transcript
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
                .frame(maxHeight: 300)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    TranscriptionView()
}
