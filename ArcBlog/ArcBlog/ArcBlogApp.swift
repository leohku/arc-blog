//
//  ArcBlogApp.swift
//  ArcBlog
//
//  Created by Leo Ho on 28/10/2023.
//

import SwiftUI

@main
struct ArcBlogApp: App {
    @Environment(\.openWindow) var openWindow
    @StateObject private var connectionStore = ConnectionStore()
    
    var body: some Scene {
        MenuBarExtra("Arc Blogs", systemImage: "character.book.closed.fill") {
            Text("Arc Blogs")
            Text("Last updated: Today 4:33PM")
            Divider()
            Button("Turn Off Streaming") {
            }
            .keyboardShortcut("t")
            Button("Publish Manually") {
            }
            .keyboardShortcut("p")
            .disabled(true)
            Divider()
            Button("Settings") {
                openWindow(id: "settings-window")
            }
            .keyboardShortcut(",")
            Button("Test") {
                Task {
                    do {
                        try await connectionStore.saveLastUpdated(lastUpdated: Date())
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        Window("Settings", id: "settings-window") {
            SettingsView(connection: $connectionStore.connection)
        }
    }
}
