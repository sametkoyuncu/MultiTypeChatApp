//
//  ContentView.swift
//  MultiTypeChatApp
//
//  Created by Samet Koyuncu on 6.12.2025.
//

import SwiftUI

/// Hosts the chat timeline with no additional chrome for previews.
struct ContentView: View {
    var body: some View {
        MessageListView()
    }
}

#Preview {
    MessageListView(previewMessages: MockDataLoader.loadPreviewMessages())
}
