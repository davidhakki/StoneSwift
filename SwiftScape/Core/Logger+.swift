//
//  Logger+.swift
//  SwiftScape
//
//  Created by David Hakki on 5/25/24.
//

import Foundation
import OSLog

extension Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    
    static let server = Logger(subsystem: subsystem, category: "server")
    static let client = Logger(subsystem: subsystem, category: "client")
    static let player = Logger(subsystem: subsystem, category: "player")
}
