//
//  SocketManager.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftWebSocket

protocol SocketManaging {
}

protocol SocketManagerDelegate {
    func send(json: Dictionary<String, Any>)
    func received(json: Dictionary<String, Any>)
}

final class SocketManager: NSObject, SocketManaging {
    static let sharedInstance = SocketManager()
    
    var webSocket: WebSocket?
    var delegate: SocketManagerDelegate?
    
    private override init() {
        super.init()
        configureWebSocket()
    }
    
    fileprivate func configureWebSocket() {
        var messageNum = 0
        webSocket = WebSocket("wss://localhost:8000/ws")
        if let ws = webSocket {
            let send : ()->() = {
                messageNum += 1
                let msg = "\(messageNum): \(NSDate().description)"
                print("send: \(msg)")
                ws.send(msg)
            }
            ws.event.open = {
                print("opened")
                send()
            }
            ws.event.close = { code, reason, clean in
                print("close")
            }
            ws.event.error = { error in
                print("error \(error)")
            }
            ws.event.message = { message in
                if let text = message as? String {
                    print("recv: \(text)")
                    if messageNum == 10 {
                        ws.close()
                    } else {
                        send()
                    }
                }
            }
        }
    }
}
