//
//  ConnectionInfo.swift
//  ArcBlog
//
//  Created by Leo Ho on 29/10/2023.
//

import Foundation

class ConnectionStore: ObservableObject {
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
