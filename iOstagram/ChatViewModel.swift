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
    
    // TODO: Complete this
}
