//
//  ChatViewModel.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import Foundation

class ChatViewModel: ObservableObject {
//    private var webSocketTask: URLSessionWebSocketTask?
    @Published var channels: [UUID: Channel] = [:]
    @Published var username: String = ""
    
    init() {
        Task {
            await refreshChannels()
        }
    }
    
    func makeChannel(channelName: String) async {
        if let newChannel = try? await NetworkManager.instance.makeChannel(channelName: channelName) {
            DispatchQueue.main.async {
                self.channels[newChannel.channelId] = newChannel
            }
        }
    }
    
    func makePost(content: String, channelId: UUID) async {
        let post = Post(author: username, content: content, createdAt: Date())
        guard let channel = channels[channelId] else { return }
        do {
            try await NetworkManager.instance.makePost(post: post, channelName: channel.name)
            DispatchQueue.main.async {
                self.channels[channelId]!.posts.append(post)
                self.channels[channelId]!.lastUpdatedAt = Date()
            }
        } catch let error {
            print(error)
        }
    }
    
    func refreshChannels() async {
        do {
            let newChannels = try await NetworkManager.instance.getChannels()
            DispatchQueue.main.async {
                self.channels = newChannels.reduce(into: [:]) { $0[$1.channelId] = $1 }
            }
        } catch let error {
            print("Error refreshing channels \(error)")
        }
    }
    
    func refreshPosts(channelId: UUID) async {
        guard let channel = channels[channelId] else { return }
        if let newPosts = try? await NetworkManager.instance.getPosts(channelName: channel.name) {
            DispatchQueue.main.async {
                self.channels[channelId]!.posts = newPosts
                self.channels[channelId]!.lastUpdatedAt = Date()
            }
        }
    }
    
//    init() {
//        connect()
//    }
//
//    private func connect() {
//        guard let url = URL(string: "ws://localhost:8080") else { return }
//        let request = URLRequest(url: url)
//        webSocketTask = URLSession.shared.webSocketTask(with: request)
//        webSocketTask?.resume()
//        listenForMessages()
//    }
//
//    private func listenForMessages() {
//        webSocketTask?.receive { result in
//            switch result {
//            case .failure(let error):
//                print("Error receiving message: \(error)")
//            case .success(let contents):
//                switch contents {
//                case .string(let text):
//                    if let data = text.data(using: .utf8),
//                       let message = try? JSONDecoder().decode(Message.self, from: data) {
//                        if let channelId = message.channelId {
//                            self.channels[channelId]?.messages.append(message)
//                        }
//                    }
//                case .data(let data):
//                    if let message = try? JSONDecoder().decode(Message.self, from: data) {
//                        if let channelId = message.channelId {
//                            self.channels[channelId]?.messages.append(message)
//                        }
//                    }
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//    func sendMessage(_ message: Message, toChannel channel: Channel) {
//        var messageToSend = message
//        messageToSend.channelId = channel.id
//        if let jsonData = try? JSONEncoder().encode(messageToSend),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            webSocketTask?.send(.string(jsonString)) { error in
//                if let error = error {
//                    print("Error sending message: \(error)")
//                }
//            }
//        }
//    }
}
