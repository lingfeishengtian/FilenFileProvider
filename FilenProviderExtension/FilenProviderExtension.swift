//
//  FileProviderExtension.swift
//  FileProviderExtension
//
//  Created by Hunter Han on 2/23/23.
//

import FileProvider
import UniformTypeIdentifiers

class FilenProviderExtension: NSObject, NSFileProviderReplicatedExtension {
    let nodeCommunicator: NodeCommunicator
    let domain: NSFileProviderDomain
    
    @objc func startNode() {
        let srcPath = Bundle.main.path(forResource: "nodejs-project/main.js", ofType: "")
        let args = ["node", srcPath]
        
        NodeRunner.startEngine(withArguments: args as [Any])
    }
    
    required init(domain: NSFileProviderDomain) {
        // TODO: The containing application must create a domain using `NSFileProviderManager.add(_:, completionHandler:)`. The system will then launch the application extension process, call `FileProviderExtension.init(domain:)` to instantiate the extension for that domain, and call methods on the instance.
        print(domain.identifier)
        self.nodeCommunicator = NodeCommunicator(domain: domain)
        self.domain = domain
        super.init()
        
        nodeCommunicator.checkNodeServer()
    }
    
    func invalidate() {
        // TODO: cleanup any resources
    }
    
    // Downloads item metadata
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        // resolve the given identifier to a record in the model
        print(identifier)
        
        completionHandler(FilenProviderItem(identifier: identifier, metadata: [:]), nil)
        return Progress()
    }
    
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: a new item was created on disk, process the item's creation
        
        let urlExists = url != nil
        let contentTypeExists = itemTemplate.contentType?.conforms(to: UTType.folder)
        
        if !urlExists, let isFolder = contentTypeExists {
            if isFolder {
                nodeCommunicator.createFolder(withName: itemTemplate.filename, at: itemTemplate.parentItemIdentifier)
            } else {
                completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain,
                                                          code: NSFeatureUnsupportedError,
                                                          userInfo: ["userDomain" : domain,
                                                                     "errorMessage" : "Symlinks and Alias are not supported"]))
            }
        } else {
            nodeCommunicator.createItem(withName: itemTemplate.filename, at: itemTemplate.parentItemIdentifier, withContents: url!)
        }
        
        completionHandler(itemTemplate, [], false, nil)
        return Progress()
    }
    
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: an item was modified on disk, process the item's modification
        
        completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        return FilenProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier, isWorkingSet: containerItemIdentifier == NSFileProviderItemIdentifier.workingSet)
    }
}
