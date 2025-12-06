import Foundation

/// Shared metadata for all chat message types.
/// Contains sender info, avatar icon, and the timestamp used by message bubbles.
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
