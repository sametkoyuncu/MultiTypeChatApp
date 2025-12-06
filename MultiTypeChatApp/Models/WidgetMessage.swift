import SwiftUI

/// An interactive widget (e.g., quick reply choices) embedded in the chat.
struct WidgetMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let title: String
    let subtitle: String
    let choices: [String]
    let meta: MessageMeta

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case choices
    }

    init(id: UUID = UUID(), title: String, subtitle: String, choices: [String], meta: MessageMeta = .demo(senderName: "Sohbet Botu", avatarSystemImage: "sparkles", minutesAgo: 8)) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.choices = choices
        self.meta = meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.choices = try container.decodeIfPresent([String].self, forKey: .choices) ?? []
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.meta = .demo(senderName: "Sohbet Botu", avatarSystemImage: "sparkles", minutesAgo: 8)
    }

    @ViewBuilder
    func toView() -> some View {
        WidgetMessageView(title: title, subtitle: subtitle, choices: choices)
    }
}
