// PlayerDetailView.swift
import SwiftUI

struct PlayerDetailView: View {
    let player: PlayerEssentials
    @ObservedObject var viewModel: SearchViewModel
    let onSaveProfile: () -> Void
    let onNewSearch: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#0f0f1e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Action buttons
                    HStack(spacing: 15) {
                        Button {
                            onSaveProfile()
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Save Profile")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Constants.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            onNewSearch()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("New Search")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    PlayerHeaderView(player: player)
                    
                    if player.league?.name.contains("Legend") == true {
                        TrophyChartView(playerTag: player.playerTag)
                    }
                    
                    LeagueInfoView(player: player)
                    
                    PlayerStatsView(player: player)
                    
                    UnitProgressionView(player: player)
                }
                .padding()
            }
            .refreshable {
                await viewModel.refreshPlayer()
            }
        }
        .navigationTitle("Player Details")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.showSuccess {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Profile Saved Successfully!")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
