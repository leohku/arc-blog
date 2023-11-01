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
        let persistedData = connectionStore.connection.persistedData
        let connectionState = connectionStore.connection.state
        let lastUpdatedDateString =
            persistedData.lastUpdated != nil ?
            formatter.string(from: persistedData.lastUpdated!) :
            "Never"
        
        Text(connectionState.statusText())
        Text("Last updated: \(lastUpdatedDateString)")
        Divider()
        Button("Turn \(persistedData.streaming ? "Off" : "On") Streaming") {
            Task {
                do {
                    try await connectionStore.saveStreaming(streaming: !persistedData.streaming)
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
        .disabled(persistedData.streaming || connectionState == ConnectionState.disconnected)
        .keyboardShortcut("p")
        Divider()
        Button("Settings") {
            openWindow(id: "settings-window")
        }
        .keyboardShortcut(",")
        Button("Quit Arc Blogs") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
