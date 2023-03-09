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
    
    // TODO: NodeJS Implement
    public func getItemMetadata(for identifier: NSFileProviderItemIdentifier) {
        // Make API call and retrieve item metadata, should get at least the following information
        // 1. Filename
        // 2. File Metadata (optional)
        // 3. Creation date, last modified date, last used (optional)
        // 4. Document size, children count (if folder), item type (should use extension?)
        // If the item doesn't exist, return that error
    }
    
    // TODO: NodeJS Implement
    public func downloadItem(for identifier: NSFileProviderItemIdentifier, version: NSFileVersion) {
        // Download the item with identifier with version (can ignore for now)
        // Use fileURL provided
        let fileURL = makeTemporaryURL("fetchContents")
    }
}
