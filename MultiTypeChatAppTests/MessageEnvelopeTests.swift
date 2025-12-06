import XCTest
@testable import MultiTypeChatApp

final class MessageEnvelopeTests: XCTestCase {
    func testDecodesAllMessageTypes() throws {
        let json = """
        [
          { "type": "text", "text": "Hello" },
          { "type": "system", "text": "Warning", "severity": "warning" },
          { "type": "quote", "author": "Tester", "quote": "Trust but verify" },
          { "type": "widget", "title": "Poll", "subtitle": "Choose", "choices": ["A", "B"] }
        ]
        """

        let envelopes = try JSONDecoder().decode([MessageEnvelope].self, from: Data(json.utf8))
        XCTAssertEqual(envelopes.count, 4)

        XCTAssertTrue(envelopes[0].message is TextMessage)
        XCTAssertTrue(envelopes[1].message is SystemMessage)
        XCTAssertTrue(envelopes[2].message is QuoteMessage)
        XCTAssertTrue(envelopes[3].message is WidgetMessage)
    }
}
