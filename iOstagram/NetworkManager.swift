//
//  NetworkManager.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import Foundation

enum NetworkError: String, Error {
    case networkError
    case invalidURL
}

class NetworkManager {
    static let instance = NetworkManager()
    
    let baseUrl = "http://localhost:3000"
    
    func getChannels() async throws -> [Channel] {
        guard let url = URL(string: "\(baseUrl)/channels") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
            
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkError.networkError
        }
        
        return try JSONDecoder().decode([Channel].self, from: data)
    }
    
    func makeChannel(channelName: String) async throws -> Channel {
        // BEWARE ENCODING ISSUES -> see makePost
        guard let url = URL(string: "\(baseUrl)/channels?channel=\(channelName)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
            
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkError.networkError
        }
        
        return try JSONDecoder().decode(Channel.self, from: data)
    }
    
    func getPosts(channelName: String) async throws -> [Post] {
        // BEWARE ENCODING ISSUES -> see makePost
        guard let url = URL(string: "\(baseUrl)/posts?channel=\(channelName)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
            
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkError.networkError
        }
        
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func makePost(post: Post, channelName: String) async throws {
        var components = URLComponents(string: "\(baseUrl)/posts")!
        components.queryItems = [
            URLQueryItem(name: "channel", value: channelName)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(post)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            throw NetworkError.networkError
        }
    }
}
