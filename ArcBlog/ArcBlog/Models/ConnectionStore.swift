//
//  ConnectionInfo.swift
//  ArcBlog
//
//  Created by Leo Ho on 29/10/2023.
//

import Foundation

struct Connection {
    var test: String
    var state: ConnectionState
    var persistedData: PersistedData
    
    init(state: ConnectionState = .disconnected) {
        self.test = "HELLO"
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
    
    init() {}
}

struct Settings: Codable {
    var serverUrl: URL
    var serverPassword: String
    var space: String
}

class ConnectionStore: ObservableObject {
    @Published var connection: Connection = Connection()
    
    init() {
        Task(priority: .medium) {
            do {
                try await load()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ArcBlog")
            .appendingPathComponent("connection.json")
    }
    
    func load() async throws {
        let task = Task<PersistedData, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return PersistedData()
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
    
    func saveSettings(settings: Settings) async throws {
        // TODO: check if new connection is valid first before saving to disk
        let task = Task {
            var persistedData = self.connection.persistedData
            persistedData.settings = settings
            let data = try JSONEncoder().encode(persistedData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func saveLastUpdated(lastUpdated: Date) async throws {
        let task = Task {
            var persistedData = self.connection.persistedData
            persistedData.lastUpdated = lastUpdated
            let data = try JSONEncoder().encode(persistedData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
