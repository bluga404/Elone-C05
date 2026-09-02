//
//  SearchButton.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct SearchButton: View {
    
    var body: some View {
        Button {
            print("Search tapped")
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .tint(.black)
    }
    
}

#Preview {
    SearchButton()
}
