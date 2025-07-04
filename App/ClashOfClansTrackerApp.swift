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
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabState.selectedTab) {
                NavigationStack {
                    SearchPlayersView()
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(TabSection.search)
                
                NavigationStack {
                    MyProfileView()
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
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
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .modelContainer(dataController.container)
            .environmentObject(tabState)
            .task {
                if await dataController.hasProfile() {
                    tabState.selectedTab = .profile
                }
            }
        }
    }
}

// Tab state management
class TabState: ObservableObject {
    static let shared = TabState()
    @Published var selectedTab: TabSection = .search
    
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
}
