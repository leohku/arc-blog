//
//  FilePresenter.swift
//  ArcBlog
//
//  Created by Leo Ho on 31/10/2023.
//

import Foundation

protocol FilePresenterDelegate: AnyObject {
    func fileDidChange()
}

class FilePresenter: NSObject, NSFilePresenter {
    weak var delegate: FilePresenterDelegate?
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue
    
    init(fileURL: URL) {
        presentedItemURL = fileURL
        presentedItemOperationQueue = OperationQueue()
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    func presentedItemDidChange() {
        if let _ = presentedItemURL {
            delegate?.fileDidChange()
        }
    }
}
