//
//  ContentView.swift
//  BooBooPharmacy
//
//  Created by Hunter Han on 2/23/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Add domain", action: {
                    let domain = NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "eggsDee"), displayName: "PEEPEE")
                    NSFileProviderManager.add(domain, completionHandler: { (err) in
                        print(err?.localizedDescription)
                    })
            })
            Button("Remove domain", action: {
                    let domain = NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "eggsDee"), displayName: "PEEPEE")
                NSFileProviderManager.remove(domain, completionHandler: { (err) in
                    print(err?.localizedDescription)
                })
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
