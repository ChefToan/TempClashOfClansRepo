// PlayerStatsView.swift
import SwiftUI

struct PlayerStatsView: View {
    let player: PlayerEssentials
    
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
                StatRow(label: "War Stars", value: "\(player.warStars)")
                StatRow(label: "Donations", value: "\(player.donations)")
                StatRow(label: "Donations Received", value: "\(player.donationsReceived)")
                StatRow(label: "Defense Wins", value: "\(player.defenseWins)")
                StatRow(label: "Capital Contributions", value: "\(player.clanCapitalContributions)")
            }
            .background(Constants.cardBackground)
        }
        .cornerRadius(12)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding()
        
        if label != "Capital Contributions" {
            Divider()
        }
    }
}
