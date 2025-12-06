import SwiftUI

/// Renders quick reply buttons and shows the user’s selection for widget messages.
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
