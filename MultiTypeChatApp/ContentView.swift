//
//  ContentView.swift
//  MultiTypeChatApp
//
//  Created by Samet Koyuncu on 6.12.2025.
//

import SwiftUI

/// Hosts the chat timeline with no additional chrome for previews.
struct ContentView: View {
    var body: some View {
        MessageListView()
    }
}

/// Displays the streaming list of chat messages and simulates async loading.
struct MessageListView: View {
    @State private var messages: [any ChatMessageDisplayable] = []
    @State private var isLoading = false

    /// Allows injecting preview data to bypass loading animations in SwiftUI previews.
    init(previewMessages: [any ChatMessageDisplayable] = []) {
        _messages = State(initialValue: previewMessages)
        _isLoading = State(initialValue: previewMessages.isEmpty)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(messages.indices, id: \.self) { index in
                        let message = messages[index]
                        MessageBubble(message: message)
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

    /// Sequentially loads messages to mimic streaming delivery.
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

    /// Fetches demo content with a small delay to keep the loading state visible.
    private func fetchMessages() async -> [any ChatMessageDisplayable] {
        try? await Task.sleep(nanoseconds: 800_000_000)
        return MockDataLoader.loadMessages()
    }
}

/// Wraps any chat message inside a bubble that renders avatar, sender name, and timestamp.
struct MessageBubble: View {
    let message: any ChatMessageDisplayable

    private var formattedTime: String {
        message.meta.timestamp.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: message.meta.avatarSystemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(message.meta.senderName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                message.toView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MessageListView(previewMessages: MockDataLoader.loadPreviewMessages())
}
