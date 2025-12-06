//
//  ContentView.swift
//  MultiTypeChatApp
//
//  Created by Samet Koyuncu on 6.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var messages: [any ChatMessageDisplayable] = MockDataLoader.loadMessages()

    var body: some View {
        NavigationStack {
            MessageListView(messages: messages)
                .navigationTitle("Chat")
        }
    }
}

struct MessageListView: View {
    let messages: [any ChatMessageDisplayable]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(messages.enumerated()), id: \.element.id) { _, message in
                    message.toView()
                        .id(message.id)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
