//
//  BackButton.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct BackButton: View {
    
    var body: some View {
        Button {
            print("Back tapped")
        } label: {
            Image(systemName: "chevron.left")
                .font(.title2)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .tint(.black)
    }
    
}

#Preview {
    BackButton()
}
