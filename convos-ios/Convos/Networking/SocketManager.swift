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
    func send(packetType: String, json: JSON)
}

protocol SocketManagerDelegate {
    func received(packet: Packet)
}

class Packet: NSObject, APIModel {
    // vars
    let type: String
    let serverTimestamp: Int?
    let data: JSON
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let typeJSON = dictionary["Type"],
            let dataJSON = dictionary["Data"] else {
                return nil
        }
        type = typeJSON.stringValue
        data = dataJSON
        serverTimestamp = dictionary["ServerTimestamp"]?.int
    }
    
    init(type: String, data: JSON) {
        self.type = type
        self.data = data
        self.serverTimestamp = nil
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["Type": JSON(type), "Data": data]
        if let serverTimestamp = serverTimestamp {
            dict["ServerTimestamp"] = JSON(serverTimestamp)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Packet(type: type, data: data)
    }
}

final class SocketManager: NSObject, SocketManaging {    
    static let sharedInstance = SocketManager()
    
    var webSocket: WebSocket?
    var delegates = MulticastDelegate<SocketManagerDelegate>()
    
    private var retryConnectionCount = 0
    
    // MARK: SocketManaging
    
    func send(packetType: String, json: JSON) {
        let packet = Packet(type: packetType, data: json)
        if let rawPacket = try? packet.toJSON().rawData() {
            webSocket?.send(rawPacket)
        } else {
            print("Failed to send packet. could not be conveted to JSON")
        }
    }
    
    func createWebSocket(accessToken: String) {
        if webSocket != nil {
            webSocket?.close()
        }
        self.generateWebSocket(token: "Bearer " + accessToken)
    }
    
    // MARK: Private
    
    fileprivate func generateWebSocket(token: String) {
        var urlRequest = URLRequest(url: URL(string: "ws://localhost:8000/ws")!)
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
                    if let p = Packet(json: jsonMessage) {
                        self.delegates.invoke{
                            $0.received(packet: p)
                        }
                    } else {
                        print("failed to turn json message into a packet")
                    }
                }
            }
            ws.open()
        }
    }
}
