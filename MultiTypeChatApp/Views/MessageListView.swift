import SwiftUI

/// Displays the streaming list of chat messages and simulates async loading.
struct MessageListView: View {
    @State private var messages: [any ChatMessageDisplayable] = []
    @State private var isLoading = false
    private let shouldAutoLoad: Bool

    /// Allows injecting preview data to bypass loading animations in SwiftUI previews.
    init(previewMessages: [any ChatMessageDisplayable] = []) {
        _messages = State(initialValue: previewMessages)
        _isLoading = State(initialValue: previewMessages.isEmpty)
        self.shouldAutoLoad = previewMessages.isEmpty
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
            .navigationTitle("Sohbet")
        }
        .onAppear {
            guard shouldAutoLoad else { return }
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
