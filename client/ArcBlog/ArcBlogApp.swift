//
//  ArcBlogApp.swift
//  ArcBlog
//
//  Created by Leo Ho on 28/10/2023.
//

import SwiftUI
import ServiceManagement

struct TransparentEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

@main
struct ArcBlogApp: App {
    @Environment(\.openWindow) var openWindow
    @StateObject private var connectionStore = ConnectionStore()
    @StateObject private var sidebarStore = SidebarStore()
    @State private var firstLaunchExperience: Bool = false
    
    init() {
        do {
            if try !FileManager.default.fileExists(atPath: appSupportDirectoryURL().path) {
                _firstLaunchExperience = State(initialValue: true)
                try FileManager.default.createDirectory(
                    atPath: appSupportDirectoryURL().path,
                    withIntermediateDirectories: false,
                    attributes: nil)
            }
        } catch {
            showFatalErrorAndQuit(
                title: ErrorTitle.failedToInitialize.rawValue,
                text: error.localizedDescription)
        }
    }
    
    var body: some Scene {
        MenuBarExtra("Arc Blog", systemImage: "character.book.closed.fill") {
            MenuBarView()
                .environmentObject(connectionStore)
                .task {
                    Task {
                        if firstLaunchExperience { try launchOnboarding() }
                    }
                }
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
    
    private func launchOnboarding() throws {
        let alert = NSAlert()
        alert.messageText = "Launch Arc Blog on login?"
        alert.informativeText = "This ensures your blog stays up to date. You can always change it later."
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let modalResult = alert.runModal()
        if modalResult == .alertFirstButtonReturn {
            try SMAppService.mainApp.register()
        }
        openWindow(id: "settings-window")
    }
}
