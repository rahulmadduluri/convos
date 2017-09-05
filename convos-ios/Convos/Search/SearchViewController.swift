//
//  SearcViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 8/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftWebSocket

class SearchViewController: UIViewController {

    var searchTextField: SearchTextField = SearchTextField()
    var conversationVC: ConversationViewController?
    
    var webSocket: WebSocket?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebSocket()
        configureSearchTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureSubviews()
    }
    
    // MARK: private
    
    fileprivate func configureSubviews() {
        searchTextField.frame = CGRect(x: 100, y: 200, width: 200, height: 100)
        self.view.addSubview(searchTextField)
    }
    
    fileprivate func configureSearchTextField() {
        searchTextField.startVisibleWithoutInteraction = true
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition  in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            
            if self.conversationVC != nil {
                self.conversationVC = ConversationViewController()
            }
            
            if let newVC = self.conversationVC {
                self.present(newVC, animated: true, completion: nil)
            }
            print("Item at position \(itemPosition): \(item.title)")
        }
        
        searchTextField.userStoppedTypingHandler = {
            if let searchText = self.searchTextField.text {
                if searchText.characters.count > 0 {
                    self.searchTextField.showLoadingIndicator()
                    self.searchForResultsInBackground(searchText) { results in
                        self.searchTextField.filterItems(results)
                        self.searchTextField.stopLoadingIndicator()
                    }
                }
            }
        }
    }
    
    fileprivate func searchForResultsInBackground(_ searchText: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
        var results = [SearchTextFieldItem]()
        for index in 0...2 {
            var item: SearchTextFieldItem?
            switch index {
            case 0:
                item = SearchTextFieldItem(title: "Rahul", subtitle: "#Vienna", image: UIImage(named: "test_profile"))
            case 1:
                item = SearchTextFieldItem(title: "Prafulla", subtitle: "#Baller", image: UIImage(named: "test_profile"))
            default:
                item = SearchTextFieldItem(title: "Reia", subtitle: "#Scrub", image: UIImage(named: "test_profile"))
            }
            if let i = item {
                results.append(i)
            }
        }
        callback(results)
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
