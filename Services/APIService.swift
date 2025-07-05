// APIService.swift
import Foundation

class APIService {
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
        guard let url = URL(string: "\(baseURL)/player/essentials?tag=\(formattedTag)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 404 {
                    throw APIError.playerNotFound
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let player = try JSONDecoder().decode(PlayerEssentials.self, from: data)
                return player
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError
            }
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // Get chart URL for player - Not async, just returns URL
    func getChartURL(tag: String) -> URL? {
        let formattedTag = formatTag(tag)
        let urlString = "\(baseURL)/chart?tag=\(formattedTag)"
        return URL(string: urlString)
    }
    
    // Force refresh by bypassing cache
    func refreshPlayerEssentials(tag: String) async throws -> PlayerEssentials {
        let formattedTag = formatTag(tag)
        guard let url = URL(string: "\(baseURL)/player/essentials?tag=\(formattedTag)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 404 {
                    throw APIError.playerNotFound
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let player = try JSONDecoder().decode(PlayerEssentials.self, from: data)
                return player
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError
            }
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    private func formatTag(_ tag: String) -> String {
        var formatted = tag.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // Remove any # symbols first
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        // Then add back a single # at the beginning
        formatted = "#\(formatted)"
        return formatted.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? formatted
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case playerNotFound
    case serverError(Int)
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .playerNotFound:
            return "Player not found. Please check the tag and try again."
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
