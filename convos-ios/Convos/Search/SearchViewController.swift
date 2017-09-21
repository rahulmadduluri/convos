//
//  SearcViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 8/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, SocketManagerDelegate {

    var searchTextField: SearchTextField = SearchTextField()
    var conversationVC: ConversationViewController?
    
    let socketManager: SocketManager = SocketManager.sharedInstance
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureSubviews()
    }
    
    // MARK: SocketManagerDelegate
    
    func received(json: Dictionary<String, Any>) {
        //fill search query data w/ results
    }
    
    func send(json: Dictionary<String, Any>) {
        // package search query into a JSON object and send
    }
    
    // MARK: Private
    
    fileprivate func configureSubviews() {
        searchTextField.frame = CGRect(x: 100, y: 200, width: 200, height: 100)
        self.view.addSubview(searchTextField)
    }
    
    fileprivate func configureSearchTextField() {
        searchTextField.startVisibleWithoutInteraction = true
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition  in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            
            if self.conversationVC == nil {
                self.conversationVC = ConversationViewController()
            }
            
            if let newVC = self.conversationVC {
                self.present(newVC, animated: false, completion: nil)
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
                item = SearchTextFieldItem(title: "Rahul", subtitle: "#Vienna", image: UIImage(named: "rahul_test_pic"))
            case 1:
                item = SearchTextFieldItem(title: "Prafulla", subtitle: "#Baller", image: UIImage(named: "praful_test_pic"))
            case 2:
                item = SearchTextFieldItem(title: "Reia", subtitle: "#Scrub", image: UIImage(named: "reia_test_pic"))
            default:
                item = SearchTextFieldItem(title: "Rahul", subtitle: "#Vienna", image: UIImage(named: "rahul_test_pic"))
            }
            if let i = item {
                results.append(i)
            }
        }
        callback(results)
    }
        
}
