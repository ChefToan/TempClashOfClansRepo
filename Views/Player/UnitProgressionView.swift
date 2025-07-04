// UnitProgressionView.swift
import SwiftUI

struct UnitProgressionView: View {
    let player: PlayerEssentials
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("UNIT PROGRESSION")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
            
            // Content
            VStack(spacing: 16) {
                // Total progress
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("TOTAL PROGRESSION")
//                        .font(.body)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Constants.blue)
//                            .frame(height: 40)
//                        
//                        Text(String(format: "%.1f%%", calculateTotalProgress()))
//                            .font(.body)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                    }
//                }
                
                // Heroes
                if !player.heroes.isEmpty {
                    UnitCategoryView(
                        title: "HEROES",
                        items: player.heroes,
                        color: Constants.orange
                    )
                }
                
                // Hero Equipment (organized by hero)
                let heroEquipmentByHero = getEquipmentByHero()
                if !heroEquipmentByHero.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HERO EQUIPMENT")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Progress bar for all equipment
                        let allEquipment = getAllEquipment()
                        let equipmentProgress = calculateProgress(for: allEquipment)
                        ProgressBar(value: equipmentProgress, color: Constants.purple)
                        
                        // Equipment by hero
                        ForEach(heroEquipmentByHero, id: \.0) { heroName, items in
                            if !items.isEmpty {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                                    ForEach(items.filter { $0.level > 0 }) { item in
                                        ItemView(item: item)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Pets
                if !player.pets.isEmpty {
                    UnitCategoryView(
                        title: "PETS",
                        items: player.pets,
                        color: Color.pink
                    )
                }
                
                // Troops
                if !player.elixirTroops.isEmpty {
                    UnitCategoryView(
                        title: "TROOPS",
                        items: player.elixirTroops,
                        color: Constants.purple
                    )
                }
                
                // Dark Troops
                if !player.darkElixirTroops.isEmpty {
                    UnitCategoryView(
                        title: "DARK TROOPS",
                        items: player.darkElixirTroops,
                        color: Color(hex: "#6c5ce7")
                    )
                }
                
                // Siege Machines
                if !player.siegeMachines.isEmpty {
                    UnitCategoryView(
                        title: "SIEGE MACHINES",
                        items: player.siegeMachines,
                        color: Color.orange
                    )
                }
                
                // Spells
                let allSpells = player.elixirSpells + player.darkElixirSpells
                if !allSpells.isEmpty {
                    UnitCategoryView(
                        title: "SPELLS",
                        items: allSpells,
                        color: Color.cyan
                    )
                }
            }
            .padding()
            .background(Constants.cardBackground)
        }
        .cornerRadius(12)
    }
    
    private func getAllEquipment() -> [GameItem] {
        var items: [GameItem] = []
        
        // Convert EquipmentItem to GameItem
        let equipment = player.heroEquipment
        for item in equipment.barbarianKing + equipment.archerQueen +
                    equipment.minionPrince + equipment.grandWarden +
                    equipment.royalChampion {
            items.append(GameItem(
                name: item.name,
                level: item.level,
                maxLevel: item.maxLevel,
                village: item.village,
                order: item.order
            ))
        }
        
        return items
    }
    
    private func getEquipmentByHero() -> [(String, [GameItem])] {
        var result: [(String, [GameItem])] = []
        
        // Barbarian King
        let kingItems = player.heroEquipment.barbarianKing.map { item in
            GameItem(name: item.name, level: item.level, maxLevel: item.maxLevel,
                     village: item.village, order: item.order)
        }
        if !kingItems.isEmpty { result.append(("Barbarian King", kingItems)) }
        
        // Archer Queen
        let queenItems = player.heroEquipment.archerQueen.map { item in
            GameItem(name: item.name, level: item.level, maxLevel: item.maxLevel,
                     village: item.village, order: item.order)
        }
        if !queenItems.isEmpty { result.append(("Archer Queen", queenItems)) }
        
        // Minion Prince
        let princeItems = player.heroEquipment.minionPrince.map { item in
            GameItem(name: item.name, level: item.level, maxLevel: item.maxLevel,
                     village: item.village, order: item.order)
        }
        if !princeItems.isEmpty { result.append(("Minion Prince", princeItems)) }
        
        // Grand Warden
        let wardenItems = player.heroEquipment.grandWarden.map { item in
            GameItem(name: item.name, level: item.level, maxLevel: item.maxLevel,
                     village: item.village, order: item.order)
        }
        if !wardenItems.isEmpty { result.append(("Grand Warden", wardenItems)) }
        
        // Royal Champion
        let championItems = player.heroEquipment.royalChampion.map { item in
            GameItem(name: item.name, level: item.level, maxLevel: item.maxLevel,
                     village: item.village, order: item.order)
        }
        if !championItems.isEmpty { result.append(("Royal Champion", championItems)) }
        
        return result
    }
    
    private func calculateProgress(for items: [GameItem]) -> Double {
        guard !items.isEmpty else { return 0 }
        let totalCurrent = items.reduce(0) { $0 + $1.level }
        let totalMax = items.reduce(0) { $0 + $1.maxLevel }
        return totalMax > 0 ? (Double(totalCurrent) / Double(totalMax)) * 100 : 0
    }
    
    private func calculateTotalProgress() -> Double {
        let allItems = player.heroes + getAllEquipment() + player.pets +
                       player.elixirTroops + player.darkElixirTroops +
                       player.siegeMachines + player.elixirSpells + player.darkElixirSpells
        
        guard !allItems.isEmpty else { return 0 }
        
        let totalCurrent = allItems.reduce(0) { $0 + $1.level }
        let totalMax = allItems.reduce(0) { $0 + $1.maxLevel }
        
        return totalMax > 0 ? (Double(totalCurrent) / Double(totalMax)) * 100 : 0
    }
}

struct UnitCategoryView: View {
    let title: String
    let items: [GameItem]
    let color: Color
    
    private var progress: Double {
        guard !items.isEmpty else { return 0 }
        let totalCurrent = items.reduce(0) { $0 + $1.level }
        let totalMax = items.reduce(0) { $0 + $1.maxLevel }
        return totalMax > 0 ? (Double(totalCurrent) / Double(totalMax)) * 100 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ProgressBar(value: progress, color: color)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(items.filter { $0.level > 0 }) { item in
                    ItemView(item: item)
                }
            }
        }
    }
}
