//
//  ContentView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("UpNextAI")
                    .font(.largeTitle)
                    .padding()
                
                Text("AI-Powered Content Recommendations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Test App") {
                    print("UpNextAI is working!")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
