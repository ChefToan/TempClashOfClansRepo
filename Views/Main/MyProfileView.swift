// MyProfileView.swift
import SwiftUI

struct MyProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var tabState: TabState
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#1a1a2e"), Color(hex: "#0f0f1e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if let player = viewModel.player {
                    ScrollView {
                        VStack(spacing: 16) {
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
                        await viewModel.refreshProfile()
                    }
                } else if viewModel.noProfile && !viewModel.isLoading {
                    // No profile view
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 100))
                            .foregroundColor(Constants.blue.opacity(0.7))
                        
                        VStack(spacing: 10) {
                            Text("No Profile Saved")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Search for a player and save it as your profile")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            tabState.switchToSearch()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search Now")
                            }
                            .padding()
                            .padding(.horizontal, 30)
                            .background(Constants.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadProfile()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ProfileDeleted"))) { _ in
                viewModel.clearProfile()
            }
            .overlay {
                if viewModel.isLoading && viewModel.player == nil {
                    LoadingView()
                }
            }
        }
    }
}
