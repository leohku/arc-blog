//
//  Common.swift
//  ArcBlog
//
//  Created by Leo Ho on 1/11/2023.
//

import Foundation

func appSupportDirectoryURL() throws -> URL {
    try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("Arc Blog")
}

func connectionFileURL() throws -> URL {
    try appSupportDirectoryURL().appendingPathComponent("connection.json")
}

func sidebarFileURL() throws -> URL {
    try
        appSupportDirectoryURL()
        .appendingPathComponent("sidebar.json")
}

func storableSidebarURL() throws -> URL {
    try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("Arc")
        .appendingPathComponent("StorableSidebar.json")
}

func saveEncodableToDisk(data: Encodable, url: URL) throws {
    let data = try JSONEncoder().encode(data)
    try data.write(to: url)
}
