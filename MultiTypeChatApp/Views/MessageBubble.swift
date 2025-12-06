import SwiftUI

/// Wraps any chat message inside a bubble that renders avatar, sender name, and timestamp.
struct MessageBubble<Message: ChatMessageDisplayable>: View {
    let message: Message

    private var formattedTime: String {
        message.meta.timestamp.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.1))

                Image(systemName: message.meta.avatarSystemImage)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(.tint)
            }
            .frame(width: 44, height: 44)

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
