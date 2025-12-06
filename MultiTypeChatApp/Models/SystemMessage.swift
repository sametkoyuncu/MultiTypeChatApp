import SwiftUI

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

    @ViewBuilder
    func toView() -> some View {
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
