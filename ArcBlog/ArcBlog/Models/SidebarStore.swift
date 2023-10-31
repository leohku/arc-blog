//
//  SidebarStore.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation

class SidebarStore: ObservableObject, FilePresenterDelegate {
    @Published var sidebar: Sidebar = Sidebar()
    var filePresenter: FilePresenter?
    
    init() {
        Task(priority: .medium) {
            do {
                let fileURL = try Self.storableSidebarURL()
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    showFatalErrorAndQuit(
                        title: ErrorTitle.arcIsntInstalled.rawValue,
                        text: "Can't find Arc's sidebar file, quitting.")
                }
                filePresenter = FilePresenter(fileURL: fileURL)
                filePresenter?.delegate = self
            } catch {
                showFatalErrorAndQuit(
                    title: ErrorTitle.failedToInitialize.rawValue,
                    text: error.localizedDescription)
            }
        }
    }
    
    func fileDidChange() {
        print("Sidebar changed")
        // TODO: read and parse file, save output (if first time), else compare before save, if different notify ConnectionStore
        // (it will then check if connection is established and streaming is on)
        
    }
                    
    private static func storableSidebarURL() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Arc")
            .appendingPathComponent("StorableSidebar.json")
    }
}
