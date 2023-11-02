//
//  Parser.swift
//  ArcBlog
//
//  Created by Leo Ho on 1/11/2023.
//

import Foundation
import SwiftyJSON

class SidebarParser {
    static func itemSearch(id: String, sidebar: JSON) throws -> JSON {
        for (i, elem) in sidebar["items"].enumerated() {
            if (i % 2 == 1) {
                continue
            }
            if (elem.1.string == id) {
                return sidebar["items"][i+1]
            }
        }
        throw RuntimeError("\(id) not found in items")
    }
    
    static func buildTree(id: String, sidebar: JSON) throws -> SidebarNode {
        let item: JSON = try Self.itemSearch(id: id, sidebar: sidebar)
        let nodeType: SidebarNodeType = try ({
            if item["data"]["tab"].exists() { return SidebarNodeType.tab }
            if item["data"]["arcDocument"].exists() { return SidebarNodeType.arcDocument }
            if item["data"]["easel"].exists() { return SidebarNodeType.easel }
            if item["data"]["list"].exists() { return SidebarNodeType.list }
            if item["data"]["itemContainer"].exists() { return SidebarNodeType.itemContainer }
            if item["data"]["splitView"].exists() { return SidebarNodeType.splitView }
            throw RuntimeError("\(id) node type not supported")
        }())
        let node = SidebarNode(
            id: item["id"].string!,
            type: nodeType,
            title: ({
                switch nodeType {
                    case SidebarNodeType.tab:
                        if item["title"].string != nil {
                            return item["title"].string
                        } else {
                            return item["data"]["tab"]["savedTitle"].string
                        }
                    case SidebarNodeType.easel:
                        if item["title"].string != nil {
                            return item["title"].string
                        } else {
                            return item["data"]["easel"]["title"].string
                        }
                    case
                        SidebarNodeType.list,
                        SidebarNodeType.arcDocument:
                        return item["title"].string
                    default:
                        return nil
                }
            }()),
            url: ({
                switch nodeType {
                    case SidebarNodeType.tab:
                        return item["data"]["tab"]["savedURL"].string
                    default:
                        return nil
                }
            }()),
            documentId: ({
                switch nodeType {
                    case SidebarNodeType.arcDocument:
                        return item["data"]["arcDocument"]["arcDocumentID"].string
                    default:
                        return nil
                }
            }()),
            easelId: ({
                switch nodeType {
                    case SidebarNodeType.easel:
                        return item["data"]["easel"]["easelID"].string
                    default:
                        return nil
                }
            }()),
            children: try ({
                switch nodeType {
                    case
                        SidebarNodeType.list,
                        SidebarNodeType.itemContainer,
                        SidebarNodeType.splitView:
                            return try item["childrenIds"].map{ try buildTree(id: $0.1.string!, sidebar: sidebar) }
                    default:
                        return nil
                }
            }())
        )
        return node
    }
    
    static func buildForest(id: String, sidebar: JSON) throws -> [SidebarNode] {
        let item: JSON = try Self.itemSearch(id: id, sidebar: sidebar)
        return try item["childrenIds"].map{ try buildTree(id: $0.1.string!, sidebar: sidebar) }
    }
    
    static func parse(content: String) throws -> Sidebar {
        var output = Sidebar()
        if let dataFromString = content.data(using: .utf8, allowLossyConversion: false) {
            let sidebarJson = try JSON(data: dataFromString)
            let sidebar = sidebarJson["sidebar"]["containers"][1]
            for space in sidebar["spaces"] {
                if space.1.string != nil {
                    continue
                }
                let profile = ({
                        if space.1["profile"]["default"].exists() {
                            return Profile(isDefault: true)
                        } else {
                            return Profile(
                                isDefault: false,
                                directoryBasename: space.1["profile"]["custom"]["_0"]["directoryBasename"].string!
                            )
                        }
                    }())
                let spaceObject = Space(
                    id: space.1["id"].string!,
                    title: space.1["title"].string!,
                    profile: profile,
                    topApps: try ({
                        let topAppsContainerID: String = try ({
                            for (i, elem) in sidebar["topAppsContainerIDs"].enumerated() {
                                if elem.1.string != nil {
                                    continue
                                }
                                if profile.isDefault {
                                    if elem.1["default"].exists() {
                                        return sidebar["topAppsContainerIDs"].arrayValue[i+1].string!
                                    }
                                } else {
                                    if (
                                        elem.1["custom"].exists() &&
                                        profile.directoryBasename == elem.1["custom"]["_0"]["directoryBasename"].string
                                    ) {
                                        return sidebar["topAppsContainerIDs"].arrayValue[i+1].string!
                                    }
                                }
                            }
                            throw RuntimeError("topAppsContainerID not found")
                        }())
                        return try Self.buildForest(id: topAppsContainerID, sidebar: sidebar)
                    }()),
                    unpinned: try ({
                        if space.1["containerIDs"][1].exists() {
                            return try Self.buildForest(id: space.1["containerIDs"][1].string!, sidebar: sidebar)
                        } else {
                            return []
                        }
                    })(),
                    pinned: try ({
                        if space.1["containerIDs"][3].exists() {
                            return try Self.buildForest(id: space.1["containerIDs"][3].string!, sidebar: sidebar)
                        } else {
                            return []
                        }
                    })()
                )
                output.spaces.append(spaceObject)
            }
        }
        // Print parsed JSON output
        // print(String(data: (try JSONEncoder().encode(output)), encoding: .utf8)!)
        return output
    }
}
