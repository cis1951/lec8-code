//
//  ContentView.swift
//  iOstagram
//
//  Created by Jordan Hochman on 3/14/24.
//

import SwiftUI

struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post.content)
            Text(post.author)
                .font(.subheadline)
                .lineLimit(1)
            Text(post.createdAt, style: .date)
                .font(.subheadline)
                .lineLimit(1)
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14)
            .foregroundStyle(.cyan)
        )
    }
}

#Preview {
    PostView(post: Post.mock)
}
