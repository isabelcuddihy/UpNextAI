
//
//  WelcomeView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var name: String = ""
    let onContinue: (String) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App branding
            VStack(spacing: 16) {
                Image(systemName: "sparkles.tv")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Welcome to UpNextAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your personal movie and TV recommendation assistant")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Name input
            VStack(alignment: .leading, spacing: 12) {
                Text("What should we call you?")
                    .font(.headline)
                
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
            }
            
            // Continue button
            Button {
                onContinue(name.trimmingCharacters(in: .whitespacesAndNewlines))
            } label: {
                HStack {
                    Text("Let's Get Started")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    WelcomeView { name in
        print("Name entered: \(name)")
    }
}
