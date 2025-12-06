import SwiftUI

/// A message that can be rendered on the chat timeline.
/// Each conforming type returns its own SwiftUI view via an **opaque** return type,
/// and exposes shared metadata for the bubble wrapper.
protocol ChatMessageDisplayable: Identifiable {
    associatedtype Content: View

    /// Metadata used by the bubble container (name, time, avatar).
    var meta: MessageMeta { get }

    /// Builds the concrete SwiftUI view for the message content without type erasure.
    @ViewBuilder
    func toView() -> Content
}

/// Decodes the message `type` field and routes to the matching model.
enum MessageType: String, Decodable {
    case text
    case image
    case widget
    case system
    case quote
}

/// A strongly typed wrapper that reads the `type` discriminator and decodes
/// the right message model while keeping the rendered view opaque.
enum ChatMessage: Identifiable, ChatMessageDisplayable {
    struct ContentView: View {
        let message: ChatMessage

        var body: some View {
            switch message {
            case .text(let message):
                message.toView()
            case .image(let message):
                message.toView()
            case .widget(let message):
                message.toView()
            case .system(let message):
                message.toView()
            case .quote(let message):
                message.toView()
            }
        }
    }

    typealias Content = ContentView

    case text(TextMessage)
    case image(ImageMessage)
    case widget(WidgetMessage)
    case system(SystemMessage)
    case quote(QuoteMessage)

    var id: UUID {
        switch self {
        case .text(let message):
            return message.id
        case .image(let message):
            return message.id
        case .widget(let message):
            return message.id
        case .system(let message):
            return message.id
        case .quote(let message):
            return message.id
        }
    }

    var meta: MessageMeta {
        switch self {
        case .text(let message):
            return message.meta
        case .image(let message):
            return message.meta
        case .widget(let message):
            return message.meta
        case .system(let message):
            return message.meta
        case .quote(let message):
            return message.meta
        }
    }

    @ViewBuilder
    func toView() -> ContentView {
        ContentView(message: self)
    }
}

struct MessageEnvelope: Decodable {
    let message: ChatMessage

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .text:
            self.message = .text(try TextMessage(from: decoder))
        case .image:
            self.message = .image(try ImageMessage(from: decoder))
        case .widget:
            self.message = .widget(try WidgetMessage(from: decoder))
        case .system:
            self.message = .system(try SystemMessage(from: decoder))
        case .quote:
            self.message = .quote(try QuoteMessage(from: decoder))
        }
    }
}
