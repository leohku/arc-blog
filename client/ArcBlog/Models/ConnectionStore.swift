//
//  ConnectionInfo.swift
//  ArcBlog
//
//  Created by Leo Ho on 29/10/2023.
//

import Foundation

class ConnectionStore: ObservableObject, FilePresenterDelegate {
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
        Task(priority: .medium) {
            do {
                let fileURL = try sidebarFileURL()
                filePresenter = FilePresenter(fileURL: fileURL)
                filePresenter?.delegate = self
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
        // TODO: update connection state (attempt to connect) based on obtained persisted data, if streaming is on also publish
    }
    
    func fileDidChange() {
        // TODO: check if connection is established and streaming is on, then if there are updates
        print("New version of parsed sidebar here")
    }
    
    func saveSettings(settings: Settings) async throws {
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
        // TODO: try to establish connection and publish if streaming is on, only establish connection if streaming is off
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
