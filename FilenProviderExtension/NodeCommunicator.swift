//
//  NodeCommunicator.swift
//  FilenProviderExtension
//
//  Created by Hunter Han on 3/9/23.
//

import Foundation
import FileProvider

let NODE_PATH = "http://127.0.0.1"
let NODE_PORT = "3000"
let NODE_URL = NODE_PATH + ":" + NODE_PORT

final class NodeCommunicator {
    let BASE_URL = URL(string: NODE_URL)!
    private let tempDir: URL
    
    init(domain: NSFileProviderDomain) {
        let manager = NSFileProviderManager(for: domain)
        
        if let _ = manager {
            do {
                tempDir = try manager!.temporaryDirectoryURL()
            } catch {
                fatalError("Cannot get a temp dir for " + domain.identifier.rawValue)
            }
        } else {
            fatalError("Cannot find file manager for " + domain.identifier.rawValue)
        }
    }
    
    @objc func startNode() {
        let srcPath = Bundle.main.path(forResource: "nodejs-project/main.js", ofType: "")
        let args = ["node", srcPath]
        
        NodeRunner.startEngine(withArguments: args as [Any])
    }
    
    let defaultErrorResponse = { (error: Error) in
        print(error.localizedDescription)
    }
    
    private func callNodeAPI(with request: URLRequest,
                             completion: @escaping (Data, URLResponse) -> Void,
                             errorHandler: ((Error) -> Void)?) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                if let handler = errorHandler {
                    handler(error!)
                } else {
                    self.defaultErrorResponse(error!)
                }
                
                return
            }
            
            completion(data, response!)
        }
        
        task.resume()
    }
    
    public func checkNodeServer() {
        let urlRequest = URLRequest(url: BASE_URL)
        callNodeAPI(with: urlRequest,
                    completion: { (args, resp) in
            print(args)
        }, errorHandler: { (err) in
            print("Cannot find node server, starting one...")
            
            let nodejsThread = Thread(target: self, selector: #selector(self.startNode), object: nil)
            nodejsThread.stackSize = 2 * 1024 * 1024
            nodejsThread.start()
            print(err)
        })
    }
    
    // Thanks apple :)
    // Can be ported to node if necessary
    private func makeTemporaryURL(_ purpose: String, _ ext: String? = nil) -> URL {
        if let ext = ext {
            return tempDir.appendingPathComponent("\(purpose)-\(UUID().uuidString).\(ext)")
        } else {
            return tempDir.appendingPathComponent("\(purpose)-\(UUID().uuidString)")
        }
    }

    // TODO: ADD completion handlers to everything!
    
    // TODO: NodeJS Implement
    func getItemMetadata(for identifier: NSFileProviderItemIdentifier) {
        // Make API call and retrieve item metadata, should get at least the following information
        // 1. Filename
        // 2. File Metadata (optional)
        // 3. Creation date, last modified date, last used (optional)
        // 4. Document size, children count (if folder), item type (should use extension?)
        // If the item doesn't exist, return that error
    }
    
    // TODO: NodeJS Implement
    func getFilesInDirectory(for identifier: NSFileProviderItemIdentifier) {
        // Identifier will always be a directory
        // MUST Support Working Directory, Trash Directory, Root Dirctory, and user created folders
    }
    
    // TODO: NodeJS Implement
    func downloadItem(for identifier: NSFileProviderItemIdentifier, version: NSFileProviderItemVersion) {
        // Download the item with identifier with version (can ignore for now)
        // Use fileURL provided
        let fileURL = makeTemporaryURL("fetchContents")
    }
    
    // TODO: NodeJS Implement
    func deleteItem(for identifier: NSFileProviderItemIdentifier, baseVersion: NSFileProviderItemVersion) {
        // Delete the item with identifier
    }
    
    // TODO: NodeJS Implement
    func createFolder(withName name: String, at parent: NSFileProviderItemIdentifier) {
        // Create folder with identifier at parent
    }

    // TODO: NodeJS Implement
    func createItem(withName name: String, at parent: NSFileProviderItemIdentifier, withContents contents: URL) {
        // Create item with identifier at parent with contents at URL
    }
    
    // TODO: NodeJS Implement
    func moveItem(for identifier: NSFileProviderItemIdentifier, to newParent: NSFileProviderItemIdentifier, filename: String) {
        // Move item with identifier to new parent with filename
        // Filename can be the same as the original
        // newParent can also be same as original
        // Think of like a linux mv command (can rename and move)
    }

    // TODO: NodeJS Implement
    func updateItem(for identifier: NSFileProviderItemIdentifier, withContents contents: URL) {
        // Update item's contents with identifier
    }
}
