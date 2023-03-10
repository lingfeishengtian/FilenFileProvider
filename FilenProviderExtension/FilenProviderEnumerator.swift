//
//  FileProviderEnumerator.swift
//  FileProviderExtension
//
//  Created by Hunter Han on 2/23/23.
//

import FileProvider

class FilenProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    private let enumeratedItemIdentifier: NSFileProviderItemIdentifier
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    private var workSet = false
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }


    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, isWorkingSet: Bool) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        workSet = isWorkingSet
        super.init()
    }

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */
         print(workSet)
        let nodeServer = "http:/127.0.0.1:3000/"
        let url = URL(string: nodeServer)
        print(url ?? "TEST")
        if url != nil {
            do {
                let versions = try String(contentsOf: url!)
                
                observer.didEnumerate([FilenProviderItem(identifier: NSFileProviderItemIdentifier("a file"), metadata: [:]), FilenProviderItem(identifier: NSFileProviderItemIdentifier(String(versions.description)), metadata: [:])])
            } catch {
                print (error)
            }
        }else {
            observer.didEnumerate([FilenProviderItem(identifier: NSFileProviderItemIdentifier("a file"), metadata: [:])])
        }
        observer.finishEnumerating(upTo: nil)
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        print(workSet)
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(anchor)
    }
}
