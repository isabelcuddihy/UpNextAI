//
//  ContentFeedView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import SwiftUI

struct ContentFeedView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView("Loading movies...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.shouldShowEmptyState {
                        Text("No movies found")
                            .foregroundColor(.gray)
                            .padding(.top, 100)
                    } else {
                        ForEach(viewModel.contentSections) { section in
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
        .task {
            await viewModel.loadMainFeed()
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
