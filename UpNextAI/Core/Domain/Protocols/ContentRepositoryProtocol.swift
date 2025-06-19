//
//  ContentRepositoryProtocol.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import Foundation

protocol ContentRepositoryProtocol {
    // MARK: - Content Operations
    func saveContent(_ content: Content) async throws
    func fetchAllContent() async throws -> [Content]
    func fetchContent(by category: String) async throws -> [Content]
    func deleteContent(with id: UUID) async throws
    
    // MARK: - User Interactions
    func updateContentInteraction(contentId: UUID, isLiked: Bool) async throws
    func fetchLikedContent() async throws -> [Content]
    func fetchDislikedContent() async throws -> [Content]
    
    // MARK: - User Profile Operations
    func saveUserProfile(_ profile: UserProfile) async throws
    func fetchUserProfile() async throws -> UserProfile?
    func updateUserProfile(_ profile: UserProfile) async throws
    
    // MARK: - Cleanup
    func clearOldContent(olderThan date: Date) async throws
}
