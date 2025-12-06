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
    @State private var isLoading = false

    init(previewMessages: [any ChatMessageDisplayable] = []) {
        _messages = State(initialValue: previewMessages)
        _isLoading = State(initialValue: previewMessages.isEmpty)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { _, message in
                        message.toView()
                            .id(message.id)
                    }

                    if isLoading {
                        ProgressView("Mesajlar yükleniyor...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 24)
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
        isLoading = true
        messages.removeAll()

        let loadedMessages = await fetchMessages()
        for message in loadedMessages {
            try? await Task.sleep(nanoseconds: 250_000_000)
            withAnimation(.easeIn(duration: 0.25)) {
                messages.append(message)
            }
        }

        isLoading = false
    }

    private func fetchMessages() async -> [any ChatMessageDisplayable] {
        try? await Task.sleep(nanoseconds: 800_000_000)
        return MockDataLoader.loadMessages()
    }
}

#Preview {
    MessageListView(previewMessages: MockDataLoader.loadPreviewMessages())
}
