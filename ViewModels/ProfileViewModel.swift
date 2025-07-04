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
        player = nil
        errorMessage = nil
        
        // Small delay to ensure any pending saves are complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        do {
            // Try to load from local storage
            if let savedPlayer = try await DataController.shared.getProfile() {
                self.player = savedPlayer
                self.noProfile = false
                
                // Then refresh from API in background
                Task.detached { [weak self] in
                    await self?.refreshProfile()
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
            await MainActor.run {
                self.player = refreshed
            }
            
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
        errorMessage = nil
    }
    
    func setPlayerData(_ player: PlayerEssentials) {
        self.player = player
        self.noProfile = false
        self.errorMessage = nil
        self.isLoading = false
    }
    
    func forceReload() async {
        // Force a complete reload with delay
        player = nil
        await loadProfile()
    }
}
