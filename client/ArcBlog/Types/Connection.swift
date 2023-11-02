//
//  Connection.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation
import SwiftUI

struct Connection {
    var state: ConnectionState
    var persistedData: PersistedData
    var error: Error?
    
    init(state: ConnectionState = .disconnected) {
        self.state = state
        self.persistedData = PersistedData()
    }
}

enum ConnectionState: Equatable {
    case disconnected, connecting, connected, failed
    
    func statusText() -> String {
        switch self {
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Connected"
            case .failed:
                return "Connection failed"
        }
    }
    
    func statusColor() -> Color {
        switch self {
            case .disconnected:
                return .gray
            case .connecting:
                return .yellow
            case .connected:
                return .green
            case .failed:
                return .red
        }
    }
}

struct PersistedData: Codable {
    var settings: Settings?
    var lastUpdated: Date?
    var streaming: Bool = true
}

struct Settings: Codable {
    var serverURL: String
    var secretKey: String
    var space: String
}
