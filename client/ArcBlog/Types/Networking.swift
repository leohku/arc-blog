//
//  Networking.swift
//  ArcBlog
//
//  Created by Leo Ho on 2/11/2023.
//

import Foundation

struct ClientRequest: Codable {
    var space: String?
}

struct ServerResponse: Codable {
    var version: String
    var update: Bool
    var error: String?
}
