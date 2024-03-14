//
//  ChatModel.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import Foundation

struct Channel { // TODO: Add conformances
    let channelId: UUID
    let name: String
    var posts: [Post]
    var lastUpdatedAt: Date
    
    var id: String {
        "\(channelId)-\(lastUpdatedAt)"
    }
    
    enum CodingKeys: String, CodingKey {
        case channelId = "id"
        case name
        case posts
    }
    
    init(channelId: UUID = UUID(), name: String, posts: [Post], lastUpdatedAt: Date = Date()) {
        self.channelId = channelId
        self.name = name
        self.posts = posts
        self.lastUpdatedAt = lastUpdatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.channelId = try container.decode(UUID.self, forKey: .channelId)
        self.name = try container.decode(String.self, forKey: .name)
        self.posts = try container.decode([Post].self, forKey: .posts)
        self.lastUpdatedAt = Date()
    }
}

struct Post { // TODO: Add conformances
    let id: UUID
    let author: String
    let content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), author: String, content: String, createdAt: Date = Date()) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
    }
}

extension Channel {
    static let mock = Channel(name: "General", posts: [Post.mock, Post(author: "Author", content: "Mock content"), Post(author: "Author 2", content: "Mock content 2")])
}

extension Post {
    static let mock = Post(author: "Bob Smith", content: "This is a great post!")
}
