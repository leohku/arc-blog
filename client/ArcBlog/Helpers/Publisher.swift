//
//  Publisher.swift
//  ArcBlog
//
//  Created by Leo Ho on 2/11/2023.
//

import Foundation

class Publisher {
    private static func makeNetworkRequest(url: String, body: String) async throws {
        let url = URL(string: "\(url)/arc-blog-admin/update")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RuntimeError("Network response unsuccessful")
        }

        guard !data.isEmpty else {
            throw RuntimeError("Invalid data")
        }
        
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }

        let decodedResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
        if !decodedResponse.success {
            throw RuntimeError(decodedResponse.error!)
        }
    }
    
    static func establishConnection(url: String, key: String) async throws {
        let body = try String(
            data: JSONEncoder().encode(
                ClientRequest(secret_key: key)),
            encoding: .utf8
        )!
        try await Self.makeNetworkRequest(url: url, body: body)
    }
    
    static func publish(url: String, key: String, data: Space) async throws {
        let stringifiedSpace = try String(
            data: JSONEncoder().encode(data),
            encoding: .utf8
        )
        let body = try String(
            data: JSONEncoder().encode(
                ClientRequest(
                    secret_key: key,
                    space: stringifiedSpace
                )),
            encoding: .utf8
        )!
        try await Self.makeNetworkRequest(url: url, body: body)
    }
}
