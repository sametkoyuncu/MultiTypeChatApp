import SwiftUI

/// Plain text chat content with a simple colored bubble background.
struct TextMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let text: String
    let meta: MessageMeta

    private enum CodingKeys: String, CodingKey {
        case id
        case text
    }

    init(id: UUID = UUID(), text: String, meta: MessageMeta = .demo(senderName: "Ada Lovelace", avatarSystemImage: "person.fill", minutesAgo: 2)) {
        self.id = id
        self.text = text
        self.meta = meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.meta = .demo(senderName: "Ada Lovelace", avatarSystemImage: "person.fill", minutesAgo: 2)
    }

    func toView() -> AnyView {
        AnyView(
            Text(text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.1))
                )
        )
    }
}
