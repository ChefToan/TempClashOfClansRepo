// ProfileViewModel.swift
import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var player: PlayerEssentials?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var noProfile = false
    
    private let apiService = APIService.shared
    
    func loadProfile() async {
        isLoading = true
        noProfile = false
        player = nil // Clear existing player data
        
        do {
            // Try to load from local storage
            if let savedPlayer = try await DataController.shared.getProfile() {
                self.player = savedPlayer
                
                // Then refresh from API in background
                Task {
                    await refreshProfile()
                }
            } else {
                noProfile = true
            }
        } catch {
            errorMessage = error.localizedDescription
            noProfile = true
        }
        
        isLoading = false
    }
    
    func refreshProfile() async {
        guard let currentPlayer = player else { return }
        
        do {
            let refreshed = try await apiService.refreshPlayerEssentials(tag: currentPlayer.playerTag)
            self.player = refreshed
            
            // Save updated data
            try await DataController.shared.saveProfile(refreshed)
        } catch {
            // Silent fail for background refresh
            print("Background refresh failed: \(error)")
        }
    }
    
    func clearProfile() {
        player = nil
        noProfile = true
    }
}
