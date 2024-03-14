//
//  ContentView.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import SwiftUI

struct ChannelView: View {
    let channelId: UUID
    @ObservedObject var chatViewModel: ChatViewModel
    var channel: Channel {
        chatViewModel.channels[channelId] ?? Channel.mock
    }
    
    @State var newPostText: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(channel.posts) { post in
                        PostView(post: post)
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $newPostText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Post") {
                    Task {
                        await chatViewModel.makePost(content: newPostText, channelId: channel.channelId)
                        newPostText = ""
                    }
                }
                .disabled(newPostText.isEmpty)
            }
            .padding()
        }
        .padding()
        .navigationTitle(channel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChannelView(channelId: Channel.mock.channelId, chatViewModel: ChatViewModel())
}
