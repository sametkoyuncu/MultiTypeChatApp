import SwiftUI

/// A short quote paired with its author.
struct QuoteMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let author: String
    let quote: String
    let meta: MessageMeta

    private enum CodingKeys: String, CodingKey {
        case id
        case author
        case quote
    }

    init(id: UUID = UUID(), author: String, quote: String, meta: MessageMeta = .demo(senderName: "Derya", avatarSystemImage: "book.fill", minutesAgo: 12)) {
        self.id = id
        self.author = author
        self.quote = quote
        self.meta = meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.author = try container.decode(String.self, forKey: .author)
        self.quote = try container.decode(String.self, forKey: .quote)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.meta = .demo(senderName: "Derya", avatarSystemImage: "book.fill", minutesAgo: 12)
    }

    func toView() -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("“" + quote + "”")
                    .font(.body)
                Text(author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.purple.opacity(0.08))
            )
            .overlay(alignment: .topLeading) {
                Image(systemName: "quote.opening")
                    .foregroundStyle(.purple)
                    .padding(6)
            }
        )
    }
}
