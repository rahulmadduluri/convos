//
//  SocketManager.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftWebSocket

protocol SocketManaging {
    func send(json: JSON)
}

protocol SocketManagerDelegate {
    func received(json: JSON)
}

final class SocketManager: NSObject, SocketManaging {
    static let sharedInstance = SocketManager()
    
    var webSocket: WebSocket?
    var delegate: SocketManagerDelegate?
    
    // MARK: Init
    
    private override init() {
        super.init()
        configureWebSocket()
    }
    
    // MARK: SocketManaging
    
    func send(json: JSON) {
        if let data = try? json.rawData() {
            webSocket?.send(data)
        } else {
            print("Failed to send. JSON object could not be converted to type Data")
        }
    }
    
    // MARK: Private
    
    fileprivate func configureWebSocket() {
        webSocket = WebSocket("wss://localhost:8000/ws")
        webSocket?.allowSelfSignedSSL = true
        if let ws = webSocket {
            ws.event.open = {
                print("Web Socket Opened!")
            }
            ws.event.close = { code, reason, clean in
                print("Web Socket Closed!")
                print(reason)
                print("Trying to reopen")
                //ws.open()
                print("Web Socket Reopened!")
            }
            ws.event.error = { error in
                print("error \(error)")
            }
            ws.event.message = { message in
                let jsonMessage = JSON(message)
                self.delegate?.received(json: jsonMessage)
            }
            ws.open()
        }
    }
}
