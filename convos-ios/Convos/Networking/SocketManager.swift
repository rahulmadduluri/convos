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
    func createWebSocket(accessToken: String)
}

protocol SocketManagerDelegate {
    func received(obj: Any)
}

final class SocketManager: NSObject, SocketManaging {    
    static let sharedInstance = SocketManager()
    
    var webSocket: WebSocket?
    var delegates = MulticastDelegate<SocketManagerDelegate>()
    
    private var retryConnectionCount = 0
    
    // MARK: SocketManaging
    
    func createWebSocket(accessToken: String) {
        if webSocket != nil {
            webSocket?.close()
        }
        self.generateWebSocket(token: "Bearer " + accessToken)
    }
    
    // MARK: Private
    
    fileprivate func generateWebSocket(token: String) {
        // TODO: make this mqtt
        var urlRequest = URLRequest(url: URL(string: "ws://mqttBroker")!)
        // add "Authorization" and "X-Uuid" fields to match HTTP calls (to verify auth token + user uuid)
        urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(APIHeaders.uuidValue(), forHTTPHeaderField: "X-Uuid")
        self.webSocket = WebSocket(request: urlRequest)
        if let ws = self.webSocket {
            ws.event.open = {
                print("Web Socket Opened!")
            }
            ws.event.close = { code, reason, clean in
                print("Web Socket Closed!")
                print("Trying to reopen")
                Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { _ in
                    ws.open()
                })
            }
            ws.event.error = { error in
                print("error \(error)")
            }
            ws.event.message = { message in
                if let message = message as? String {
                    let jsonMessage = JSON(parseJSON: message)
                    self.delegates.invoke{
                        $0.received(obj: jsonMessage)
                    }
                }
            }
            ws.open()
        }
    }
}
