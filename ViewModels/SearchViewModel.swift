// SearchViewModel.swift
import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchTag = ""
    @Published var isLoading = false
    @Published var player: PlayerEssentials?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    
    private let apiService = APIService.shared
    
    func searchPlayer() async {
        guard !searchTag.isEmpty else {
            errorMessage = "Please enter a player tag"
            showError = true
            HapticManager.shared.errorFeedback()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let player = try await apiService.getPlayerEssentials(tag: searchTag)
            self.player = player
            HapticManager.shared.successFeedback()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            HapticManager.shared.errorFeedback()
        }
        
        isLoading = false
    }
    
    func saveAsProfile() async -> Bool {
        guard let player = player else { return false }
        
        isLoading = true
        
        do {
            try await DataController.shared.saveProfile(player)
            showSuccess = true
            HapticManager.shared.successFeedback()
            
            // Clear search state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.searchTag = ""
                self.player = nil
                self.showSuccess = false
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to save profile"
            showError = true
            HapticManager.shared.errorFeedback()
            isLoading = false
            return false
        }
    }
    
    func refreshPlayer() async {
        guard let currentPlayer = player else { return }
        
        isLoading = true
        
        do {
            let refreshed = try await apiService.refreshPlayerEssentials(tag: currentPlayer.playerTag)
            self.player = refreshed
        } catch {
            errorMessage = "Failed to refresh"
            showError = true
        }
        
        isLoading = false
    }
}
