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
                let fileURL = try storableSidebarURL()
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    showFatalErrorAndQuit(
                        title: ErrorTitle.arcIsntInstalled.rawValue,
                        text: "Can't find Arc's sidebar file, quitting.")
                }
                filePresenter = FilePresenter(fileURL: fileURL)
                filePresenter?.delegate = self
                fileDidChange()
            } catch {
                showFatalErrorAndQuit(
                    title: ErrorTitle.failedToInitialize.rawValue,
                    text: error.localizedDescription)
            }
        }
    }
    
    func fileDidChange() {
        DispatchQueue.main.async {
            do {
                let content = try String(contentsOfFile: storableSidebarURL().path, encoding: .utf8)
                self.sidebar = try SidebarParser.parse(content: content)
                try saveEncodableToDisk(
                    data: self.sidebar,
                    url: sidebarFileURL())
            } catch {
                showError(
                    title: ErrorTitle.unableToParseSidebar.rawValue,
                    text: error.localizedDescription)
            }
        }
    }
}
