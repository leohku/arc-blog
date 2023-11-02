//
//  Sidebar.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation

struct Sidebar: Codable, Hashable {
    var spaces: [Space]
    
    init() {
        spaces = []
    }
}

struct Profile: Codable, Hashable {
    var isDefault: Bool
    var directoryBasename: String?
}

enum SidebarNodeType: String, Codable, Hashable {
    case tab, arcDocument, easel, list, itemContainer, splitView
}

struct SidebarNode: Codable, Hashable {
    var id: String
    var type: SidebarNodeType
    var title: String?
    var url: String?
    var documentId: String?
    var easelId: String?
    var  children: [SidebarNode]?
}

struct Space: Codable, Hashable {
    var id: String
    var title: String
    var profile: Profile
    var topApps: [SidebarNode]
    var unpinned: [SidebarNode]
    var pinned: [SidebarNode]
}
