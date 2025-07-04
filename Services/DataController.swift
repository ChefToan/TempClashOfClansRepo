// DataController.swift
import Foundation
import SwiftData

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
        
        // Delete any existing profiles first
        let descriptor = FetchDescriptor<PlayerModel>()
        let existing = try context.fetch(descriptor)
        for profile in existing {
            context.delete(profile)
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
        
        try context.save()
    }
    
    func getProfile() async throws -> PlayerEssentials? {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PlayerModel>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        
        guard let model = try context.fetch(descriptor).first,
              let data = model.essentialsData else {
            return nil
        }
        
        return try JSONDecoder().decode(PlayerEssentials.self, from: data)
    }
    
    func hasProfile() async -> Bool {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PlayerModel>()
        let count = try? context.fetchCount(descriptor)
        return (count ?? 0) > 0
    }
    
    func deleteProfile() async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PlayerModel>()
        let profiles = try context.fetch(descriptor)
        
        for profile in profiles {
            context.delete(profile)
        }
        
        try context.save()
    }
}
