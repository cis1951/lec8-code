//
//  ChatViewModel.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import Foundation

@MainActor @Observable class ChatViewModel {
    var channels: [UUID: Channel] = [:]
    var username: String = ""
    
    // TODO: Complete this
}
