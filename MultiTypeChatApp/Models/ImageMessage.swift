import SwiftUI

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
