//
//  SelectButton.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct SelectButton: View {
    
    var body: some View {
        Button {
            print("Select tapped")
        } label: {
            Text("Select")
                .font(.title2)
                .padding(.horizontal, 30)
                .frame(height: 44)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .tint(.black)
    }
    
}

#Preview {
    SelectButton()
}
