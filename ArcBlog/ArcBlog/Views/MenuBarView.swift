//
//  MenuBarExtraView.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow

    var body: some View {
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
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
