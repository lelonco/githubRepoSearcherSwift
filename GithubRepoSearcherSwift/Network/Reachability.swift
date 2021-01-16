//
//  Reachability.swift
//  TestApi
//
//  Created by Yaroslav on 20.12.2020.
//

import Foundation
import Network

public class Reachability {

    static let shared = Reachability()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")

    var isConnected = true {
        didSet {
            print(isConnected ? "has internet connetcion" : "has NOT internet connetcion")
        }
    }
    private init() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
            } else {
                self.isConnected = false
            }
        }
    }
}
