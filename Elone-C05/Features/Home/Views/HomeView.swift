//
//  HomeView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct HomeView: View {
    
    // Home View Model
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        HStack {
            BackButton()

            Spacer()

            HStack(spacing: 12) {
                SearchButton()
                SelectButton()
            }
        }
        .padding(.horizontal)
        .padding(.top)
        
        HStack {
            Text("All Recordings")
                .font(.title)
                .bold()
            Spacer()
        }
        .padding()
        
        List {
            ForEach(viewModel.recordings, id: \.self) { recording in

                HStack {
                    Button {
                        viewModel.playRecording(url: recording)
                    } label: {
                        Image(systemName: "play.fill")
                    }

                    VStack(alignment: .leading) {
                        Text(recording.deletingPathExtension().lastPathComponent)
                            .font(.headline)

                        Text(viewModel.recordingDate(recording))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .task {
            viewModel.loadRecordings()
        }
        
        Spacer()
        
        RecordButton(
            isRecording: viewModel.isRecording
        ) {
            viewModel.toggleRecording()
        }
        .padding(.bottom, 20)
    }
    
}

#Preview {
    HomeView()
}
