//
//  ArcBlogApp.swift
//  ArcBlog
//
//  Created by Leo Ho on 28/10/2023.
//

import SwiftUI

struct TransparentEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

@main
struct ArcBlogApp: App {
    @Environment(\.openWindow) var openWindow
    @StateObject private var connectionStore = ConnectionStore()
    
    var body: some Scene {
        MenuBarExtra("Arc Blogs", systemImage: "character.book.closed.fill") {
            MenuBarView()
        }
        Window("Settings", id: "settings-window") {
            SettingsView(connection: $connectionStore.connection)
                .fixedSize()
                .background(TransparentEffect().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
