//
//  ContentView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 26/08/26.
//

import SwiftUI
import whisper
import AVFoundation

struct ContentView: View {
    
    let modelUrl = Bundle.main.url(
        forResource: "ggml-base",
        withExtension: "bin"
    )
    
    init() {
        print("Model:", modelUrl?.path ?? "Not found")
        
        if let modelUrl {
            let params = whisper_context_default_params()
            let context = whisper_init_from_file_with_params(
                modelUrl.path,
                params
            )
            
            print("Whisper context:", context==nil ? "FAILED" : "SUCCESS")
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Walker!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
