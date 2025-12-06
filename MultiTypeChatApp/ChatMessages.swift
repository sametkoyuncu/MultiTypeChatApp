import SwiftUI

protocol ChatMessageDisplayable: Identifiable {
    func toView() -> AnyView
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

struct ImageMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let imageURL: String
    let caption: String

    private enum CodingKeys: String, CodingKey {
        case id
        case imageURL
        case caption
    }

    init(id: UUID = UUID(), imageURL: String, caption: String) {
        self.id = id
        self.imageURL = imageURL
        self.caption = caption
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
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

struct WidgetMessage: Identifiable, Decodable, ChatMessageDisplayable {
    let id: UUID
    let title: String
    let subtitle: String
    let choices: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case choices
    }

    init(id: UUID = UUID(), title: String, subtitle: String, choices: [String]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.choices = choices
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.choices = try container.decodeIfPresent([String].self, forKey: .choices) ?? []
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }

    func toView() -> AnyView {
        AnyView(
            WidgetMessageView(title: title, subtitle: subtitle, choices: choices)
        )
    }
}

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

enum MockDataLoader {
    static func loadMessages() -> [any ChatMessageDisplayable] {
        let jsonString = """
        [
          { "type": "text", "text": "Hello! Welcome to the chat." },
          { "type": "image", "imageURL": "https://picsum.photos/400", "caption": "A random inspiration" },
          { "type": "widget", "title": "Upcoming Meeting", "subtitle": "Today at 3 PM", "choices": ["Join", "Maybe", "Decline"] }
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
