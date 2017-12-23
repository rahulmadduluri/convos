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
}

final class SocketManager: NSObject, SocketManaging {    
    static let sharedInstance = SocketManager()
    
    var webSocket: WebSocket?
    var delegate: SocketManagerDelegate?
    
    private var retryConnectionCount = 0
    
    // MARK: Init
    
    private override init() {
        super.init()
        configureWebSocket()
    }
    
    // MARK: SocketManaging
    
    func send(packetType: String, json: JSON) {
        let packet = Packet(type: packetType, data: json)
        if let rawPacket = try? packet.toJSON().rawData() {
            webSocket?.send(rawPacket)
        } else {
            print("Failed to send packet. could not be conveted to JSON")
        }
    }
    
    // MARK: Private
    
    fileprivate func configureWebSocket() {
        webSocket = WebSocket("ws://localhost:8000/ws")
        if let ws = webSocket {
            ws.event.open = {
                print("Web Socket Opened!")
            }
            ws.event.close = { code, reason, clean in
                print("Web Socket Closed!")
                print(reason)
                if (self.retryConnectionCount < 10) {
                    print("Trying to reopen")
                    ws.open()
                    print("Web Socket Reopened!")
                } else {
                    print("error: tried to connect Web Socket too many times")
                }
            }
            ws.event.error = { error in
                print("error \(error)")
            }
            ws.event.message = { message in
                if let message = message as? String {
                    let jsonMessage = JSON(parseJSON: message)
                    if let p = Packet(json: jsonMessage) {
                        self.delegate?.received(packet: p)
                    } else {
                        print("failed to turn json message into a packet")
                    }
                }
            }
            ws.open()
        }
    }
}
