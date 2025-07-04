// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var tabState: TabState
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                List {
                    Section {
                        Toggle(isOn: $isDarkMode) {
                            Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                        }
                        .onChange(of: isDarkMode) { _, _ in
                            HapticManager.shared.selectionFeedback()
                        }
                    } header: {
                        Text("Appearance")
                    }
                    
                    Section {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Profile", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    } header: {
                        Text("Profile Management")
                    }
                    
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("Toan Pham")
                                .foregroundColor(.secondary)
                        }
                    } header: {
                        Text("About")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete Profile?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteProfile()
                        // Switch to profile tab after deletion
                        tabState.switchToProfile()
                    }
                }
            } message: {
                Text("This will permanently delete your saved profile. This action cannot be undone.")
            }
        }
    }
}
