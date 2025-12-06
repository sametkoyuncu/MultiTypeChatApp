import SwiftUI

/// A message that can be rendered on the chat timeline.
/// Each conforming type returns its own SwiftUI view via `toView()`,
/// keeping the rendering opaque to the caller while exposing shared metadata
/// for the outer container to render avatars and headers.
protocol ChatMessageDisplayable: Identifiable {
    /// Metadata used by the bubble container (name, time, avatar).
    var meta: MessageMeta { get }

    /// Builds the concrete SwiftUI view for the message content.
    func toView() -> AnyView
}

/// Decodes the message `type` field and routes to the matching model.
enum MessageType: String, Decodable {
    case text
    case image
    case widget
    case system
    case quote
}

/// A wrapper that reads the `type` discriminator and decodes the right message model.
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
        case .system:
            self.message = try SystemMessage(from: decoder)
        case .quote:
            self.message = try QuoteMessage(from: decoder)
        }
    }
}
