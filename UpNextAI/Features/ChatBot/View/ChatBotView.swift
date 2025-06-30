//
//  ChatBotView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/28/25.
//
import Foundation
import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                                    .onTapGesture {
                                        // Dismiss keyboard when tapping on messages
                                        isInputFocused = false
                                    }
                            }
                            
                            if viewModel.isTyping {
                                ChatTypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onTapGesture {
                        // Dismiss keyboard when tapping on scroll area
                        isInputFocused = false
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input Area
                ChatInputView(
                    text: $messageText,
                    onSend: {
                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.sendMessage(messageText)
                            messageText = ""
                            isInputFocused = false // Dismiss keyboard after sending
                        }
                    }
                )
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                isInputFocused = false
            }
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        switch message.type {
        case .userText(let text):
            UserMessageBubble(text: text)
        case .botText(let text):
            BotMessageBubble(text: text)
        case .movieRecommendations(let movies):
            MovieRecommendationRow(movies: movies)
        case .systemNotification(let text):
            SystemMessage(text: text)
        }
    }
}

struct UserMessageBubble: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: 280, alignment: .trailing)
        }
    }
}

struct BotMessageBubble: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: 280, alignment: .leading)
            Spacer()
        }
    }
}

struct MovieRecommendationRow: View {
    let movies: [Content]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies.prefix(5)) { movie in
                        MovieRecommendationCard(movie: movie)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MovieRecommendationCard: View {
    let movie: Content
    @State private var showingDetail = false
    @FocusState private var dismissKeyboard: Bool
    
    var body: some View {
        Button(action: {
            // Dismiss keyboard before opening sheet
            dismissKeyboard = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingDetail = true
            }
        }) {
            VStack(spacing: 8) {
                // Movie Poster Image
                AsyncImage(url: URL(string: movie.fullPosterURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "tv")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                Text(movie.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        )
                }
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 4) {
                    Text(movie.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", movie.rating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 120)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            ContentDetailView(content: movie.toTMDBContent())
        }
    }
}


struct SystemMessage: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
        }
    }
}

struct ChatTypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

struct ChatInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask for movie recommendations...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .onSubmit {
                    onSend()
                    isTextFieldFocused = false // Dismiss keyboard after sending
                }
            
            Button(action: {
                onSend()
                isTextFieldFocused = false // Dismiss keyboard after sending
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.isEmpty ? .gray : .blue)
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isTextFieldFocused = false
        }
    }
}
