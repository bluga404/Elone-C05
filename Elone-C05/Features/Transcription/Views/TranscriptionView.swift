//
//  TranscriptionView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 31/08/26.
//

import SwiftUI

struct TranscriptionView: View {

    @State private var viewModel = TranscriptionViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Transcription")
                .font(.largeTitle)
                .bold()

            Button {
                viewModel.transcribeAudio()
            } label: {
                if viewModel.isTranscribing {
                    ProgressView()
                } else {
                    Text("Transcribe Audio")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isTranscribing)

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
        }
        .padding()
    }
}

#Preview {
    TranscriptionView()
}
