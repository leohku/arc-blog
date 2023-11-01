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
                try await load()
            } catch {
                showFatalErrorAndQuit(
                    title: ErrorTitle.failedToInitialize.rawValue,
                    text: error.localizedDescription)
            }
        }
    }
    
    private func createInitConnectionFile(initData: PersistedData) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(initData)
            let outfile = try connectionFileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    private func load() async throws {
        let task = Task<PersistedData, Error> {
            guard let data = try? Data(contentsOf: connectionFileURL()) else {
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
    
    func saveSettings(settings: Settings) async throws {
        // TODO: check if new connection is valid first before saving to disk
        let task = Task {
            DispatchQueue.main.async {
                self.connection.persistedData.settings = settings
            }
            var persistedData = self.connection.persistedData
            persistedData.settings = settings
            try saveEncodableToDisk(
                data: persistedData,
                url: connectionFileURL())
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
            try saveEncodableToDisk(
                data: persistedData,
                url: connectionFileURL())
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
            try saveEncodableToDisk(
                data: persistedData,
                url: connectionFileURL())
        }
        _ = try await task.value
    }
}
