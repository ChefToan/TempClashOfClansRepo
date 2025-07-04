// DataController.swift
import Foundation
import SwiftData

enum DataControllerError: LocalizedError {
    case saveFailed
    case contextSaveFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save profile to database"
        case .contextSaveFailed:
            return "Failed to save context changes"
        }
    }
}

@MainActor
class DataController: ObservableObject {
    static let shared = DataController()
    
    let container: ModelContainer
    
    private init() {
        do {
            container = try ModelContainer(for: PlayerModel.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    func saveProfile(_ player: PlayerEssentials) async throws {
        let context = container.mainContext
        
        // Start a transaction
        context.autosaveEnabled = false
        
        // Delete any existing profiles first
        let descriptor = FetchDescriptor<PlayerModel>()
        let existing = try context.fetch(descriptor)
        for profile in existing {
            context.delete(profile)
        }
        
        // Save deletion
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw DataControllerError.contextSaveFailed
            }
        }
        
        // Create new profile
        let essentialsData = try JSONEncoder().encode(player)
        let model = PlayerModel(
            tag: player.playerTag,
            name: player.playerName,
            expLevel: player.expLevel,
            trophies: player.trophies,
            bestTrophies: player.bestTrophies,
            townHallLevel: player.townHallLevel,
            warStars: player.warStars,
            donations: player.donations,
            donationsReceived: player.donationsReceived,
            essentialsData: essentialsData
        )
        
        context.insert(model)
        
        // Force save immediately
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
            throw DataControllerError.contextSaveFailed
        }
        
        // Re-enable autosave
        context.autosaveEnabled = true
        
        // Small delay to ensure persistence
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify save was successful
        let verifyDescriptor = FetchDescriptor<PlayerModel>(
            predicate: #Predicate { $0.tag == player.playerTag }
        )
        let savedModels = try context.fetch(verifyDescriptor)
        
        if savedModels.isEmpty {
            throw DataControllerError.saveFailed
        }
    }
    
    func getProfile() async throws -> PlayerEssentials? {
        let context = container.mainContext
        
        // Force fetch fresh data
        let descriptor = FetchDescriptor<PlayerModel>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        
        let models = try context.fetch(descriptor)
        
        guard let model = models.first,
              let data = model.essentialsData else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(PlayerEssentials.self, from: data)
        } catch {
            print("Failed to decode player essentials: \(error)")
            throw error
        }
    }
    
    func hasProfile() async -> Bool {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PlayerModel>()
        
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Failed to check profile existence: \(error)")
            return false
        }
    }
    
    func deleteProfile() async throws {
        let context = container.mainContext
        context.autosaveEnabled = false
        
        let descriptor = FetchDescriptor<PlayerModel>()
        let profiles = try context.fetch(descriptor)
        
        for profile in profiles {
            context.delete(profile)
        }
        
        if context.hasChanges {
            try context.save()
        }
        
        context.autosaveEnabled = true
        
        // Add a small delay to ensure deletion is complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
}
