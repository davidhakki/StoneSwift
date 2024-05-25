//
//  main.swift
//  SwiftScape
//
//  Created by David Hakki on 5/25/24.
//

import Foundation
import Network
import OSLog

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
    var connectedClients: Set<NWEndpoint.Host> = []

    init() {
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            Logger.server.error("Failed to create listener: \(error)")
            return
        }
        
        listener?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Server is ready and listening on port \(self.port)")
            case .failed(let error):
                Logger.server.error("Server failed with error: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { newConnection in
            if case let NWEndpoint.hostPort(host, port) = newConnection.endpoint {
                if self.connectedClients.contains(host) {
                    print("Client \(host) is already connected. Rejecting new connection.")
                    newConnection.cancel()
                } else {
                    print("New connection from \(host) on port \(port)")
                    self.connectedClients.insert(host)
                    
                    newConnection.stateUpdateHandler = { newState in
                        switch newState {
                        case .cancelled, .failed(_):
                            self.connectedClients.remove(host)
                        default:
                            break
                        }
                    }
                    
                    newConnection.start(queue: .main)
                    self.receive(on: newConnection)
                }
            }
        }

        listener?.start(queue: .main)
    }

    func receive(on connection: NWConnection) {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
                if let data = data, !data.isEmpty {
                    let hexString = data.map { String(format: "%02x", $0) }.joined()
                    Logger.client.debug("Received data (hex): \(hexString)")
                }

                if isComplete {
                    Logger.client.info("Connection Complete")
                    connection.cancel()
                } else if let error = error {
                    Logger.client.error("Connection error: \(error)")
                    connection.cancel()
                } else {
                    self.receive(on: connection)
                }
            }
        }
}
