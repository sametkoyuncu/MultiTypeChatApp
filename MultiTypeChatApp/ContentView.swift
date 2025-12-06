//
//  ContentView.swift
//  MultiTypeChatApp
//
//  Created by Samet Koyuncu on 6.12.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MessageListView()
    }
}

struct MessageListView: View {
    @State private var messages: [any ChatMessageDisplayable] = []

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Chat")
        }
        .onAppear {
            Task {
                await loadMessages()
            }
        }
    }

    @MainActor
    private func loadMessages() async {
        let loadedMessages = await fetchMessages()
        messages = loadedMessages
    }

    private func fetchMessages() async -> [any ChatMessageDisplayable] {
        MockDataLoader.loadMessages()
    }
}

#Preview {
    ContentView()
}
