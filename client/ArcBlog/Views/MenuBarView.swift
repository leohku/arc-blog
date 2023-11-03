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
    let todayFormatter: DateFormatter
    let formatter: DateFormatter
    
    
    init() {
        todayFormatter = DateFormatter()
        todayFormatter.dateStyle = .none
        todayFormatter.timeStyle = .short
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
    }
    
    func getLastUpdatedDateString(dateOptional: Date?) -> String {
        if let lastUpdated = dateOptional {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastUpdated) {
                return "Today, \(todayFormatter.string(from: lastUpdated))"
            } else {
                return formatter.string(from: lastUpdated)
            }
        } else {
            return "Never"
        }
    }

    var body: some View {
        let persistedData = connectionStore.connection.persistedData
        let connectionState = connectionStore.connection.state
        let lastUpdatedDateString = getLastUpdatedDateString(dateOptional: persistedData.lastUpdated)

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
            connectionStore.publishManually()
        }
        .disabled(!(connectionStore.connection.state == ConnectionState.connected))
        .keyboardShortcut("p")
        Divider()
        Button("Settings") {
            openWindow(id: "settings-window")
        }
        .keyboardShortcut(",")
        Button("Quit Arc Blog") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
