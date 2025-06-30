//
//  ContentFeedView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import SwiftUI

struct ContentFeedView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView("Loading movies...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.shouldShowEmptyState {
                        VStack(spacing: 16) {
                            Text("No movies found")
                                .foregroundColor(.gray)
                            
                            Button("Retry") {
                                Task {
                                    await viewModel.refresh()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.contentSections, id: \.title) { section in
                            ContentRowView(
                                title: section.title,
                                content: section.content,
                                onItemTap: { movie in
                                    viewModel.handleMovieTap(movie)
                                }
                            )
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("UpNext AI")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
        }
        // FIXED: Better view lifecycle management
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                print("🎬 ContentFeedView appeared for first time, loading content...")
                Task {
                    await viewModel.loadMainFeed()
                }
            } else {
                print("🎬 ContentFeedView reappeared, content should already be loaded")
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    ContentFeedView()
}
