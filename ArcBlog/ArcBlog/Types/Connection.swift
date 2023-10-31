//
//  Connecrtion.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation

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
