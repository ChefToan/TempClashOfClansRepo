// ClashOfClansTrackerApp.swift
import SwiftUI
import SwiftData

enum TabSection: Int {
    case search = 0
    case profile = 1
    case settings = 2
}

@main
struct ClashOfClansTrackerApp: App {
    @StateObject private var dataController = DataController.shared
    @StateObject private var tabState = TabState.shared
    @State private var hasCheckedProfile = false
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabState.selectedTab) {
                NavigationStack {
                    SearchPlayersView()
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search Players")
                }
                .tag(TabSection.search)
                
                NavigationStack {
                    MyProfileView()
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My Profile")
                }
                .tag(TabSection.profile)
                
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(TabSection.settings)
            }
            .tint(Constants.blue)
            .preferredColorScheme(.dark) // Always dark mode
            .modelContainer(dataController.container)
            .environmentObject(tabState)
            .environmentObject(dataController)
            .task {
                if !hasCheckedProfile {
                    hasCheckedProfile = true
                    // Check if user has a profile saved
                    if await dataController.hasProfile() {
                        // Start at profile tab if they have a saved profile
                        tabState.selectedTab = .profile
                    } else {
                        // Start at search tab if no profile
                        tabState.selectedTab = .search
                    }
                }
            }
        }
    }
}

// Tab state management
class TabState: ObservableObject {
    static let shared = TabState()
    @Published var selectedTab: TabSection = .search
    
    private init() {}
    
    func switchToProfile() {
        withAnimation(.spring()) {
            selectedTab = .profile
        }
    }
    
    func switchToSearch() {
        withAnimation(.spring()) {
            selectedTab = .search
        }
    }
    
    func switchToSettings() {
        withAnimation(.spring()) {
            selectedTab = .settings
        }
    }
}
