//
//  Networking.swift
//  ArcBlog
//
//  Created by Leo Ho on 2/11/2023.
//

import Foundation

struct ClientRequest: Codable {
    var secret_key: String;
    var space: String?
}

struct ServerResponse: Codable {
    var version: String
    var success: Bool
    var error: String?
}
