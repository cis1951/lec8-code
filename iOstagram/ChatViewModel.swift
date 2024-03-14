//
//  ChatViewModel.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import Foundation

@MainActor class ChatViewModel: ObservableObject {
    @Published var channels: [UUID: Channel] = [:]
    @Published var username: String = ""
    
    init() {
        Task {
            await refreshChannels()
        }
    }
    
    func makeChannel(channelName: String) async {
        if let newChannel = try? await NetworkManager.instance.makeChannel(channelName: channelName) {
            self.channels[newChannel.channelId] = newChannel
        }
    }
    
    func makePost(content: String, channelId: UUID) async {
        let post = Post(author: username, content: content, createdAt: Date())
        guard let channel = channels[channelId] else { return }
        do {
            try await NetworkManager.instance.makePost(post: post, channelName: channel.name)
            self.channels[channelId]!.posts.append(post)
            self.channels[channelId]!.lastUpdatedAt = Date()
        } catch let error {
            print(error)
        }
    }
    
    func refreshChannels() async {
        do {
            let newChannels = try await NetworkManager.instance.getChannels()
            self.channels = newChannels.reduce(into: [:]) { $0[$1.channelId] = $1 }
        } catch let error {
            print("Error refreshing channels \(error)")
        }
    }
    
    func refreshPosts(channelId: UUID) async {
        guard let channel = channels[channelId] else { return }
        if let newPosts = try? await NetworkManager.instance.getPosts(channelName: channel.name) {
            self.channels[channelId]!.posts = newPosts
            self.channels[channelId]!.lastUpdatedAt = Date()
        }
    }
}
