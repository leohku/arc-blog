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
    @StateObject private var sidebarStore = SidebarStore()
    
    init() {
        do {
            if try !FileManager.default.fileExists(atPath: appSupportDirectoryURL().path) {
                try FileManager.default.createDirectory(atPath: appSupportDirectoryURL().path, withIntermediateDirectories: false, attributes: nil)
            }
        } catch {
            showFatalErrorAndQuit(
                title: ErrorTitle.failedToInitialize.rawValue,
                text: error.localizedDescription)
        }
    }
    
    var body: some Scene {
        MenuBarExtra("Arc Blogs", systemImage: "character.book.closed.fill") {
            MenuBarView()
                .environmentObject(connectionStore)
        }
        Window("Settings", id: "settings-window") {
            SettingsView()
                .environmentObject(connectionStore)
                .environmentObject(sidebarStore)
                .fixedSize()
                .background(TransparentEffect().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
