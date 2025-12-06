import SwiftUI

/// Metadata that can be shared across different message renderers.
struct MessageMeta {
    let senderName: String
    let timestamp: Date
    let avatarSystemImage: String

    static func demo(senderName: String, avatarSystemImage: String, minutesAgo: Int) -> MessageMeta {
        MessageMeta(
            senderName: senderName,
            timestamp: Date().addingTimeInterval(TimeInterval(-minutesAgo * 60)),
            avatarSystemImage: avatarSystemImage
        )
    }
}

/// A message that can be rendered on the chat timeline.
///
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

/// Plain text chat content.
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

/// A chat item that displays a remote image and its caption.
struct ImageMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let imageURL: String
    let caption: String
    let meta: MessageMeta

    private enum CodingKeys: String, CodingKey {
        case id
        case imageURL
        case caption
    }

    init(id: UUID = UUID(), imageURL: String, caption: String, meta: MessageMeta = .demo(senderName: "Grace Hopper", avatarSystemImage: "camera.fill", minutesAgo: 5)) {
        self.id = id
        self.imageURL = imageURL
        self.caption = caption
        self.meta = meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.meta = .demo(senderName: "Grace Hopper", avatarSystemImage: "camera.fill", minutesAgo: 5)
    }

    func toView() -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}

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

    func toView() -> AnyView {
        AnyView(
            WidgetMessageView(title: title, subtitle: subtitle, choices: choices)
        )
    }
}

/// A system-level notice such as info or warning banners.
struct SystemMessage: Identifiable, Decodable, ChatMessageDisplayable {
    enum Severity: String, Decodable {
        case info
        case warning
    }

    let id: UUID
    let text: String
    let severity: Severity
    let meta: MessageMeta

    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case severity
    }

    init(id: UUID = UUID(), text: String, severity: Severity, meta: MessageMeta = .demo(senderName: "Sistem", avatarSystemImage: "exclamationmark.triangle.fill", minutesAgo: 1)) {
        self.id = id
        self.text = text
        self.severity = severity
        self.meta = meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.severity = try container.decode(Severity.self, forKey: .severity)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.meta = .demo(senderName: "Sistem", avatarSystemImage: "exclamationmark.triangle.fill", minutesAgo: 1)
    }

    func toView() -> AnyView {
        AnyView(
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: severityIcon)
                    .foregroundStyle(severityColor)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(severityColor.opacity(0.1))
            )
        )
    }

    private var severityColor: Color {
        switch severity {
        case .info:
            return .blue
        case .warning:
            return .orange
        }
    }

    private var severityIcon: String {
        switch severity {
        case .info:
            return "info.circle"
        case .warning:
            return "exclamationmark.triangle"
        }
    }
}

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

/// UI that renders quick reply buttons and shows the user’s selection.
struct WidgetMessageView: View {
    let title: String
    let subtitle: String
    let choices: [String]
    @State private var selectedChoice: String?

    private var availableChoices: [String] {
        choices.isEmpty ? ["Tamam"] : choices
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                ForEach(availableChoices, id: \.self) { choice in
                    Button {
                        selectedChoice = choice
                    } label: {
                        Text(choice)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectionBackground(for: choice))
                            )
                            .foregroundStyle(selectionForeground(for: choice))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let selectedChoice {
                Text("Seçilen: \(selectedChoice)")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.gray.opacity(0.2))
        )
    }

    private func selectionBackground(for choice: String) -> Color {
        selectedChoice == choice ? .blue.opacity(0.2) : .gray.opacity(0.1)
    }

    private func selectionForeground(for choice: String) -> Color {
        selectedChoice == choice ? .blue : .primary
    }
}

/// Provides static JSON for demos and previews and decodes them into message models.
enum MockDataLoader {
    static func loadMessages() -> [any ChatMessageDisplayable] {
        decodeMessages(from: liveJSON)
    }

    static func loadPreviewMessages() -> [any ChatMessageDisplayable] {
        decodeMessages(from: previewJSON)
    }

    /// Converts the sample JSON string into `ChatMessageDisplayable` instances.
    private static func decodeMessages(from jsonString: String) -> [any ChatMessageDisplayable] {
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

    private static let liveJSON = """
    [
      { "type": "system", "text": "Yeni sürüm hazır!", "severity": "info" },
      { "type": "text", "text": "Hello! Welcome to the chat." },
      { "type": "image", "imageURL": "https://picsum.photos/400", "caption": "A random inspiration" },
      { "type": "quote", "author": "Grace Hopper", "quote": "The most dangerous phrase in the language is, 'We've always done it this way.'" },
      { "type": "widget", "title": "Upcoming Meeting", "subtitle": "Today at 3 PM", "choices": ["Join", "Maybe", "Decline"] },
      { "type": "system", "text": "Bağlantı yavaş görünüyor, lütfen bekleyin", "severity": "warning" }
    ]
    """

    private static let previewJSON = """
    [
      { "type": "text", "text": "Örnek mesaj" },
      { "type": "quote", "author": "Atatürk", "quote": "Yurtta sulh, cihanda sulh." },
      { "type": "system", "text": "Deneme uyarısı", "severity": "info" }
    ]
    """
}
