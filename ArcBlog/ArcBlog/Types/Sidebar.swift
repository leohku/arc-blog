//
//  Sidebar.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation

struct Sidebar: Encodable {
    var spaces: [Space]
    
    init() {
        spaces = []
    }
}

struct Profile: Encodable {
    var isDefault: Bool
    var directoryBasename: String?
}

enum SidebarNodeType: String, Encodable {
    case tab, arcDocument, easel, list, itemContainer, splitView
}

struct SidebarNode: Encodable {
    var id: String
    var type: SidebarNodeType
    var title: String
    var url: String?
    var children: [SidebarNode]?
}

struct Space: Encodable {
    var id: String
    var title: String
    var profile: Profile
    var topApps: [SidebarNode]
    var unpinned: [SidebarNode]
    var pinned: [SidebarNode]
}
