// SearchPlayersView.swift
import SwiftUI

struct SearchPlayersView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var tabState: TabState
    @State private var showPlayerDetail = false
    @FocusState private var isSearchFieldFocused: Bool
    
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
                
                if viewModel.player == nil && !showPlayerDetail {
                    // Search interface
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Logo
                        ZStack {
                            Circle()
                                .fill(Constants.blue.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Constants.blue)
                        }
                        
                        // Title
                        VStack(spacing: 10) {
                            Text("Search Players")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Enter a player tag to view their stats")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Search box
                        VStack(spacing: 20) {
                            HStack {
                                Text("#")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                
                                TextField("Player Tag", text: $viewModel.searchTag)
                                    .textFieldStyle(.plain)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .autocapitalization(.allCharacters)
                                    .disableAutocorrection(true)
                                    .focused($isSearchFieldFocused)
                                    .onSubmit {
                                        if !viewModel.searchTag.isEmpty {
                                            performSearch()
                                        }
                                    }
                                
                                if !viewModel.searchTag.isEmpty {
                                    Button {
                                        viewModel.searchTag = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            
                            Button {
                                performSearch()
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    Text("Search")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.searchTag.isEmpty ? Color.gray : Constants.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                            }
                            .disabled(viewModel.searchTag.isEmpty || viewModel.isLoading)
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        isSearchFieldFocused = false
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showPlayerDetail) {
                if let player = viewModel.player {
                    PlayerDetailView(
                        player: player,
                        viewModel: viewModel,
                        onSaveProfile: {
                            Task {
                                let saved = await viewModel.saveAsProfile()
                                if saved {
                                    // Wait a bit to ensure data is fully saved
                                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                                    
                                    // Navigate away from detail view first
                                    showPlayerDetail = false
                                    
                                    // Then switch to profile tab
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        tabState.switchToProfile()
                                    }
                                }
                            }
                        },
                        onNewSearch: {
                            viewModel.player = nil
                            viewModel.searchTag = ""
                            showPlayerDetail = false
                            // Focus the search field when going back
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isSearchFieldFocused = true
                            }
                        }
                    )
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .overlay {
                if viewModel.isLoading && viewModel.player == nil {
                    LoadingView()
                }
            }
        }
    }
    
    private func performSearch() {
        isSearchFieldFocused = false
        Task {
            await viewModel.searchPlayer()
            if viewModel.player != nil {
                showPlayerDetail = true
            }
        }
    }
}
