//
//  Errors.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation
import Cocoa

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

enum ErrorTitle: String {
    case failedToInitialize = "Failed to Initialize"
    case arcIsntInstalled = "Arc isn't Installed"
    case unableToSave = "Unable to Save"
    case unableToParseSidebar = "Unable to Parse Sidebar File"
    case unableToConnect = "Unable to Connect"
}

func showError(title: String, text: String) -> Void {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

func showFatalErrorAndQuit(title: String, text: String) -> Void {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }
}
