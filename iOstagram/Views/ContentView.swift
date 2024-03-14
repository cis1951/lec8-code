//
//  ContentView.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var chatViewModel = ChatViewModel()
    
    @State var selectedChannel: Channel?
    @State var shouldSetName = true
    
    @State var createNewChannel = false
    @State var newChannelName = ""
        
    var body: some View {
        NavigationSplitView {
            VStack {
                List(Array(chatViewModel.channels.values), selection: $selectedChannel) { channel in
                    NavigationLink(
                        destination: {
                            ChannelView(channelId: channel.channelId, chatViewModel: chatViewModel)
                        },
                        label: {
                            Text("**\(channel.name)**")
                        }
                    )
                }
                .refreshable {
                    await chatViewModel.refreshChannels()
                }
            }
            .navigationTitle("Channels")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Channel", action: {
                        createNewChannel = true
                    })
                }
            }
            .alert("Create new channel", isPresented: $createNewChannel) {
                TextField("Channel name", text: $newChannelName)
                HStack {
                    Button("Cancel", action: {
                        createNewChannel = false
                    })
                    Button("OK", action: {
                        if !newChannelName.isEmpty {
                            Task {
                                await chatViewModel.makeChannel(channelName: newChannelName)
                                createNewChannel = false
                                newChannelName = ""
                            }
                        }
                    })
                }
            }
        } detail: {
            if let selectedChannel {
                ChannelView(channelId: selectedChannel.channelId, chatViewModel: chatViewModel)
            } else {
                Text("Choose a channel on the sidebar.")
                    .foregroundStyle(.secondary)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}
