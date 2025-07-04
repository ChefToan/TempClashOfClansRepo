// TrophyChartView.swift
import SwiftUI

struct TrophyChartView: View {
    let playerTag: String
    @State private var showFullScreen = false
    
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
                                }
                        case .failure:
                            VStack(spacing: 10) {
                                Image(systemName: "chart.line.downtrend.xyaxis")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Failed to load chart")
                                    .foregroundColor(.secondary)
                            }
                        case .empty:
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                Text("Loading chart...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Invalid player tag")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 250) // Fixed height
            .clipped() // Ensure content doesn't overflow
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            if let url = chartURL {
                print("Loading chart from URL: \(url.absoluteString)")
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let url = chartURL {
                ImageViewer(url: url, isPresented: $showFullScreen)
            }
        }
    }
}
