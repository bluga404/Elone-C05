//
//  HomeView.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 01/09/26.
//

import SwiftUI

struct HomeView: View {
    
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
        
        Spacer()
        
    }
    
}

#Preview {
    HomeView()
}
