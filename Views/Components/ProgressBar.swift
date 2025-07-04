// ProgressBar.swift
import SwiftUI

struct ProgressBar: View {
    let value: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                
                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: geometry.size.width * (value / 100))
                
                // Text
                Text(String(format: "%.1f%%", value))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 24)
    }
}
