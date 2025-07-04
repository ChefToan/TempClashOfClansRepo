// LeagueInfoView.swift
import SwiftUI

struct LeagueInfoView: View {
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
            Text("LEAGUE INFO")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)

            // Content
            VStack(spacing: 24) {
                // Current League Section
                VStack(spacing: 16) {
                    Text("Current League")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Image(systemName: "shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Constants.purple)
                    
                    if let league = player.league {
                        Text(league.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)

                        Text(formatNumber(player.trophies))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }

                // Current Rankings (Legends)
                if let legends = player.legends {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    VStack(spacing: 12) {
                        Text("Current Rankings")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 60) {
                            VStack(spacing: 8) {
                                Text("Global:")
                                    .font(.body)
                                    .foregroundColor(.secondary)

                                if let rank = legends.globalRank {
                                    Text("#\(formatNumber(rank))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Unranked")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }

                            VStack(spacing: 8) {
                                Text("Local:")
                                    .font(.body)
                                    .foregroundColor(.secondary)

                                if let rank = legends.localRank {
                                    Text("#\(formatNumber(rank))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Unranked")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal)
                
                // All time best
                VStack(spacing: 16) {
                    Text("All time best")
                        .font(.headline)
                        .foregroundColor(.white)

                    Image(systemName: "shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Constants.purple.opacity(0.8))

                    if player.league != nil {
                        Text("Legend")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)

                        Text(formatNumber(player.bestTrophies))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            .frame(maxWidth: .infinity) // Ensure it fills horizontally
            .background(Constants.cardBackground)
        }
        .frame(maxWidth: .infinity) // Ensure outer VStack stretches
        .cornerRadius(12)
    }

    
    private func formatNumber(_ number: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
