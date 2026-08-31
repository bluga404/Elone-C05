//
//  ContentView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 26/08/26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = TranscriptionViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("Transcribe") {
                viewModel.transcribeAudio()
            }

            if viewModel.isTranscribing {
                ProgressView("Transcribing...")
            }

            Text(viewModel.transcript)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
