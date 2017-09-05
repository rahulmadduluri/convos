//
//  SearcViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 8/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var searchTextField: SearchTextField = SearchTextField()
    var conversationVC: ConversationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureSubviews()
    }
    
    func configureSubviews() {
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
    
}
