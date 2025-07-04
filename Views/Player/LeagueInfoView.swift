// LeagueInfoView.swift
import SwiftUI

struct LeagueInfoView: View {
    let player: PlayerEssentials
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("LEAGUE INFO")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
            
            // Content
            VStack(spacing: 16) {
                // Current trophies
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.title)
                    
                    Text("\(player.trophies)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                // League name
                if let league = player.league {
                    Text(league.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                // Rankings (if in legends)
                if let legends = player.legends {
                    HStack(spacing: 40) {
                        VStack {
                            Text("Global")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(legends.globalRank.map { "#\($0)" } ?? "Unranked")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Local")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(legends.localRank.map { "#\($0)" } ?? "Unranked")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Divider()
                
                // Best trophies
                VStack(spacing: 8) {
                    Text("Personal Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(player.bestTrophies)")
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
            .background(Constants.cardBackground)
        }
        .cornerRadius(12)
    }
}
