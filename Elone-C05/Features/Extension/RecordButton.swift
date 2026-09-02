//
//  RecordButton.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct RecordButton: View {

    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(.red)
                .frame(width: 62, height: 62)
                .overlay {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
        }
        .buttonStyle(.plain)
        .padding(8)
        .glassEffect(.regular, in: .circle)
    }
}
