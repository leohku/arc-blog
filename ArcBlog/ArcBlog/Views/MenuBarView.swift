//
//  MenuBarExtraView.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var connectionStore: ConnectionStore
    let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
    }

    var body: some View {
        Text("Arc Blogs")
        let lastUpdatedDateString =
            connectionStore.connection.persistedData.lastUpdated != nil ?
            formatter.string(from: connectionStore.connection.persistedData.lastUpdated!) :
            "Never"
        Text("Last updated: \(lastUpdatedDateString)")
        Divider()
        let streaming =
            connectionStore.connection.persistedData.streaming
        Button("Turn \(streaming ? "Off" : "On") Streaming") {
            Task {
                do {
                    try await connectionStore.saveStreaming(streaming: !streaming)
                } catch {
                    showError(
                        title: ErrorTitle.unableToSave.rawValue,
                        text: error.localizedDescription)
                }
            }
        }
        .keyboardShortcut("t")
        Button("Publish Manually") {
        }
        .disabled(streaming)
        .keyboardShortcut("p")
        Divider()
        Button("Settings") {
            openWindow(id: "settings-window")
        }
        .keyboardShortcut(",")
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
