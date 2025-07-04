// APIService.swift
import Foundation

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.cheftoan.com"
    private let cache = URLCache(
        memoryCapacity: 10 * 1024 * 1024,  // 10 MB
        diskCapacity: 50 * 1024 * 1024,     // 50 MB
        diskPath: "clash_api_cache"
    )
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    // Get player essentials with caching
    func getPlayerEssentials(tag: String) async throws -> PlayerEssentials {
        let formattedTag = formatTag(tag)
        let url = URL(string: "\(baseURL)/player/essentials?tag=\(formattedTag)")!
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let player = try JSONDecoder().decode(PlayerEssentials.self, from: data)
        return player
    }
    
    // Get chart URL for player - Fixed URL construction
    func getChartURL(tag: String) -> URL? {
        let formattedTag = formatTag(tag)
        let urlString = "\(baseURL)/chart?tag=\(formattedTag)"
        print("Chart URL: \(urlString)") // Debug log
        return URL(string: urlString)
    }
    
    // Force refresh by bypassing cache
    func refreshPlayerEssentials(tag: String) async throws -> PlayerEssentials {
        let formattedTag = formatTag(tag)
        let url = URL(string: "\(baseURL)/player/essentials?tag=\(formattedTag)")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let player = try JSONDecoder().decode(PlayerEssentials.self, from: data)
        return player
    }
    
    private func formatTag(_ tag: String) -> String {
        var formatted = tag.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if !formatted.hasPrefix("#") {
            formatted = "#\(formatted)"
        }
        return formatted.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? formatted
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case serverError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
