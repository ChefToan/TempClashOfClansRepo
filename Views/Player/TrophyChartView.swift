// TrophyChartView.swift
import SwiftUI

struct TrophyChartView: View {
    let playerTag: String
    @State private var showFullScreen = false
    @State private var hasError = false
    @State private var isLoading = true
    @State private var retryCount = 0
    
    private var chartURL: URL? {
        APIService.shared.getChartURL(tag: playerTag)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TROPHY PROGRESSION")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
            }
            
            // Fixed height container for chart
            ZStack {
                // Background
                Color(UIColor.secondarySystemBackground)
                
                if let url = chartURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    showFullScreen = true
                                    HapticManager.shared.lightImpactFeedback()
                                }
                                .onAppear {
                                    isLoading = false
                                    hasError = false
                                }
                        case .failure:
                            VStack(spacing: 10) {
                                Image(systemName: "chart.line.downtrend.xyaxis")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Failed to load chart")
                                    .foregroundColor(.secondary)
                                
                                Button {
                                    retryCount += 1
                                } label: {
                                    Text("Retry")
                                        .font(.caption)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Constants.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .onAppear {
                                isLoading = false
                                hasError = true
                            }
                        case .empty:
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Constants.blue))
                                    .scaleEffect(1.2)
                                Text("Loading chart...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                            .onAppear {
                                isLoading = true
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .id(retryCount) // Force reload when retry is pressed
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Invalid player tag")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tap hint overlay (only show when image is loaded)
                if !isLoading && !hasError && chartURL != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.caption2)
                                Text("Tap to view full screen")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .padding(8)
                        }
                    }
                }
            }
            .frame(height: 250) // Fixed height
            .clipped() // Ensure content doesn't overflow
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .fullScreenCover(isPresented: $showFullScreen) {
            if let url = chartURL {
                ImageViewer(url: url, isPresented: $showFullScreen)
            }
        }
    }
}
