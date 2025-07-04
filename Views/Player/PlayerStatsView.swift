// PlayerStatsView.swift
import SwiftUI

struct PlayerStatsView: View {
    let player: PlayerEssentials
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("PLAYER STATS")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
            
            // Stats list
            VStack(spacing: 0) {
                StatRow(label: "Level", value: "\(player.expLevel)")
                StatRow(label: "War Stars", value: formatNumber(player.warStars))
                StatRow(label: "Donations", value: formatNumber(player.donations))
                StatRow(label: "Donations Received", value: formatNumber(player.donationsReceived))
                StatRow(label: "Defense Wins", value: formatNumber(player.defenseWins))
                StatRow(label: "Capital Contributions", value: formatNumber(player.clanCapitalContributions))
                
                if let warPreference = player.warPreference {
                    StatRow(label: "War Preference", value: warPreference.capitalized)
                }
            }
            .background(Constants.cardBackground)
        }
        .cornerRadius(12)
    }
    
    private func formatNumber(_ number: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundColor(.secondary)
                    .font(.body)
                
                Spacer()
                
                Text(value)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .font(.body)
            }
            .padding()
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
    }
}
