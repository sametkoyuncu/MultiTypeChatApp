import SwiftUI

protocol ChatMessageDisplayable {
    func toView() -> some View
}

struct TextMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let text: String

    private enum CodingKeys: String, CodingKey {
        case id
        case text
    }

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }

    func toView() -> some View {
        Text(text)
    }
}

struct ImageMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let imageName: String

    private enum CodingKeys: String, CodingKey {
        case id
        case imageName
    }

    init(id: UUID = UUID(), imageName: String) {
        self.id = id
        self.imageName = imageName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }

    func toView() -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}

struct WidgetMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let title: String
    let subtitle: String

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
    }

    init(id: UUID = UUID(), title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }

    func toView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
