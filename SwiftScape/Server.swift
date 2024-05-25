//
//  main.swift
//  SwiftScape
//
//  Created by David Hakki on 5/25/24.
//

import Foundation
import Network

@main
struct Main {
    static func main() {
        let server = TCPServer()
        RunLoop.main.run()
    }
}

class TCPServer {
    let port: NWEndpoint.Port = 30712
    var listener: NWListener?

    init() {
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            print("Failed to create listener: \(error)")
            return
        }
        
        listener?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Server is ready and listening on port \(self.port)")
            case .failed(let error):
                print("Server failed with error: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { newConnection in
            newConnection.start(queue: .main)
            self.receive(on: newConnection)
        }

        listener?.start(queue: .main)
    }

    func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                let receivedString = String(data: data, encoding: .utf8) ?? "Received non-text data"
                print("Received data: \(receivedString)")
            }

            if isComplete {
                connection.cancel()
            } else if let error = error {
                print("Connection error: \(error)")
                connection.cancel()
            } else {
                self.receive(on: connection)
            }
        }
    }
}
