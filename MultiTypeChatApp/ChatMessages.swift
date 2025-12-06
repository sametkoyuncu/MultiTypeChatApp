import SwiftUI

protocol ChatMessageDisplayable {
    func toView() -> some View
}

enum MessageType: String, Decodable {
    case text
    case image
    case widget
}

struct MessageEnvelope: Decodable {
    let message: any ChatMessageDisplayable

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .text:
            self.message = try TextMessage(from: decoder)
        case .image:
            self.message = try ImageMessage(from: decoder)
        case .widget:
            self.message = try WidgetMessage(from: decoder)
        }
    }
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

enum MockDataLoader {
    static func loadMessages() -> [any ChatMessageDisplayable] {
        let jsonString = """
        [
          { "type": "text", "text": "Hello! Welcome to the chat." },
          { "type": "image", "imageName": "SampleImage" },
          { "type": "widget", "title": "Upcoming Meeting", "subtitle": "Today at 3 PM" }
        ]
        """

        guard let data = jsonString.data(using: .utf8) else {
            return []
        }

        do {
            let envelopes = try JSONDecoder().decode([MessageEnvelope].self, from: data)
            return envelopes.map { $0.message }
        } catch {
            print("Failed to decode messages: \(error)")
            return []
        }
    }
}
