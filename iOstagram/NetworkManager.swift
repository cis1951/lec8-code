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
    
    let baseUrl = "https://cis1951-lec8-backend-99a1ab6d6844.herokuapp.com"
    // Use this instead if running backend locally
    // let baseUrl = "http://localhost:3000"
    
    func getChannels() async throws -> [Channel] {
        // TODO: Complete
    }
    
    func makeChannel(channelName: String) async throws -> Channel {
        // TODO: Complete
    }
    
    func getPosts(channelName: String) async throws -> [Post] {
        // TODO: Complete
    }
    
    func makePost(post: Post, channelName: String) async throws {
        // TODO: Complete
    }
}
