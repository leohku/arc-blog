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
    var cachedSpace: Space?
    
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
            Task {
                if self.connection.persistedData.settings != nil {
                    await self.initializeConnection()
                }
            }
        }
    }
    
    private func initializeConnection() async {
        do {
            self.connecting()
            if !self.connection.persistedData.streaming {
                try await Publisher.establishConnection(
                    url: self.connection.persistedData.settings!.serverURL,
                    key: self.connection.persistedData.settings!.secretKey
                )
            } else {
                try await self.publish(onlyIfNovel: true)
            }
            self.connectionSucceeded()
        } catch {
            self.connectionFailed(error: error)
        }
    }
    
    private func getPublishableData() async throws -> Space? {
        let task = Task<Sidebar, Error> {
            guard let data = try? Data(contentsOf: sidebarFileURL()) else {
                throw RuntimeError("Unable to read data in sidebar file")
            }
            let decodedData = try JSONDecoder().decode(Sidebar.self, from: data)
            return decodedData
        }
        let sidebar = try await task.value
        let space = sidebar.spaces.filter { space in
            if space.title == self.connection.persistedData.settings?.space {
                return true
            }
            return false
        }
        return space.count > 0 ? space[0] : nil
    }
    
    private func publish(onlyIfNovel: Bool) async throws {
        let space: Space? = try await self.getPublishableData()
        if space == nil || (onlyIfNovel ? space == cachedSpace : false) {
            return
        }
        print(onlyIfNovel ? "Novel data, publishing" : "Manually publishing")
        try await Publisher.publish(
            url: self.connection.persistedData.settings!.serverURL,
            key: self.connection.persistedData.settings!.secretKey,
            data: space!
        )
        cachedSpace = space
        try await self.saveLastUpdated(lastUpdated: Date())
    }
    
    private func connecting() {
        DispatchQueue.main.async {
            self.connection.state = ConnectionState.connecting
            self.connection.error = nil
        }
    }
    
    private func connectionSucceeded() {
        DispatchQueue.main.async {
            self.connection.state = ConnectionState.connected
            self.connection.error = nil
        }
    }
    
    private func connectionFailed(error: Error) {
        DispatchQueue.main.async {
            self.connection.state = ConnectionState.failed
            self.connection.error = error
        }
    }
    
    func fileDidChange() {
        Task {
            print("New version of parsed sidebar here")
            do {
                if (self.connection.state == ConnectionState.connected &&
                    self.connection.persistedData.streaming &&
                    self.connection.persistedData.settings != nil) {
                    try await self.publish(onlyIfNovel: true)
                }
            } catch {
                // TODO: Change this to log
                showError(title: ErrorTitle.unableToUpdateBlog.rawValue,
                          text: error.localizedDescription)
            }
        }
    }
    
    func publishManually() {
        Task {
            do {
                if (self.connection.state == ConnectionState.connected &&
                    self.connection.persistedData.settings != nil) {
                    try await self.publish(onlyIfNovel: false)
                }
            } catch {
                showError(title: ErrorTitle.unableToUpdateBlog.rawValue,
                          text: error.localizedDescription)
            }
        }
    }
    
    func connect(settings: Settings) async throws {
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
        await self.initializeConnection()
    }
    
    func disconnect() async throws {
        DispatchQueue.main.async {
            self.connection.state = ConnectionState.disconnected
            self.connection.error = nil
        }
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
