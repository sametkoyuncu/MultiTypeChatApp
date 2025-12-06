import Foundation

/// Provides static JSON for demos and previews and decodes them into message models.
enum MockDataLoader {
    static func loadMessages() -> [ChatMessage] {
        decodeMessages(from: liveJSON)
    }

    static func loadPreviewMessages() -> [ChatMessage] {
        decodeMessages(from: previewJSON)
    }

    /// Converts the sample JSON string into `ChatMessageDisplayable` instances.
    private static func decodeMessages(from jsonString: String) -> [ChatMessage] {
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
