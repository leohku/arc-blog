//
//  Errors.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation
import Cocoa

enum ErrorTitle: String {
    case failedToInitialize = "Failed to Initialize"
    case arcIsntInstalled = "Arc isn't Installed"
    case unableToSave = "Unable to Save"
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
