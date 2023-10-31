//
//  ConnectionInfo.swift
//  ArcBlog
//
//  Created by Leo Ho on 29/10/2023.
//

import Foundation
import Cocoa

struct Connection {
    var state: ConnectionState
    var persistedData: PersistedData
    
    init(state: ConnectionState = .disconnected) {
        self.state = state
        self.persistedData = PersistedData()
    }
}

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case failed(error: Error)
}

struct PersistedData: Codable {
    var settings: Settings?
    var lastUpdated: Date?
    var streaming: Bool = true
}

struct Settings: Codable {
    var serverUrl: URL
    var serverPassword: String
    var space: String
}

class ConnectionStore: ObservableObject, FilePresenterDelegate {
    @Published var connection: Connection = Connection()
    var filePresenter: FilePresenter?
    
    init() {
        Task(priority: .medium) {
            do {
                if try !FileManager.default.fileExists(atPath: Self.appSupportDirectoryURL().path) {
                    try FileManager.default.createDirectory(atPath: Self.appSupportDirectoryURL().path, withIntermediateDirectories: false, attributes: nil)
                }
                try await load()
            } catch {
                showFatalErrorAndQuit(
                    title: ErrorTitle.failedToInitialize.rawValue,
                    text: error.localizedDescription)
            }
        }
        Task(priority: .medium) {
            do {
                let fileURL = try Self.storableSidebarURL()
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    showFatalErrorAndQuit(
                        title: ErrorTitle.arcIsntInstalled.rawValue,
                        text: "Can't find Arc's sidebar file, quitting.")
                }
                filePresenter = FilePresenter(fileURL: fileURL)
                filePresenter?.delegate = self
            } catch {
                showFatalErrorAndQuit(
                    title: ErrorTitle.failedToInitialize.rawValue,
                    text: error.localizedDescription)
            }
        }
    }
    
    func fileDidChange() {
        print("Sidebar changed")
        // TODO: Check if connection is established, that streaming is on, if so, read file and send to server
    }
                    
    private static func storableSidebarURL() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Arc")
            .appendingPathComponent("StorableSidebar.json")
    }
    
    private static func appSupportDirectoryURL() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Arc Blog")
    }
    
    private static func connectionFileURL() throws -> URL {
        try Self.appSupportDirectoryURL().appendingPathComponent("connection.json")
    }
    
    private func createInitConnectionFile(initData: PersistedData) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(initData)
            let outfile = try Self.connectionFileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    private func load() async throws {
        let task = Task<PersistedData, Error> {
            guard let data = try? Data(contentsOf: Self.connectionFileURL()) else {
                let initData = PersistedData()
                _ = try await createInitConnectionFile(initData: initData)
                return initData
            }
            let decodedData = try JSONDecoder().decode(PersistedData.self, from: data)
            return decodedData
        }
        let persistedData = try await task.value
        DispatchQueue.main.async {
            self.connection.persistedData = persistedData
        }
        // TODO: update connection state (attempt to connect) based on obtained persisted data
    }
    
    private func saveToDisk(data: PersistedData) throws {
        let data = try JSONEncoder().encode(data)
        let outfile = try Self.connectionFileURL()
        try data.write(to: outfile)
    }
    
    func saveSettings(settings: Settings) async throws {
        // TODO: check if new connection is valid first before saving to disk
        let task = Task {
            DispatchQueue.main.async {
                self.connection.persistedData.settings = settings
            }
            var persistedData = self.connection.persistedData
            persistedData.settings = settings
            try saveToDisk(data: persistedData)
        }
        _ = try await task.value
    }
    
    func saveLastUpdated(lastUpdated: Date) async throws {
        let task = Task {
            DispatchQueue.main.async {
                self.connection.persistedData.lastUpdated = lastUpdated
            }
            var persistedData = self.connection.persistedData
            persistedData.lastUpdated = lastUpdated
            try saveToDisk(data: persistedData)
        }
        _ = try await task.value
    }
    
    func saveStreaming(streaming: Bool) async throws {
        let task = Task {
            DispatchQueue.main.async {
                self.connection.persistedData.streaming = streaming
            }
            var persistedData = self.connection.persistedData
            persistedData.streaming = streaming
            try saveToDisk(data: persistedData)
        }
        _ = try await task.value
    }
}
