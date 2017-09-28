//
//  SearcViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 8/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftWebSocket


class SearchViewController: UIViewController, SocketManagerDelegate, SearchTableVCDelegate {

    var containerView: MainSearchView? = nil
    var searchTableVC = SearchTableViewController() // search results table
    var conversationVC: ConversationViewController? // conversation VC to transition to
    
    let socketManager: SocketManager = SocketManager.sharedInstance
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
    }
    
    override func loadView() {
        self.addChildViewController(searchTableVC)
        
        containerView = MainSearchView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 450))
        
        containerView?.searchTableContainerView = searchTableVC.view
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: SearchTableVCDelegate
    
    func itemSelected(viewData: CollapsibleTableViewData) {
        if let searchViewData = viewData as? SearchViewData {
            if self.conversationVC == nil {
                let vc = ConversationViewController()
                vc.setConversationTitle(newTitle: searchViewData.text)
                self.conversationVC = ConversationViewController()
                
            }
            
            if let newVC = self.conversationVC {
                self.present(newVC, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: SocketManagerDelegate
    
    func received(json: JSON) {
        switch json["dataType"].stringValue {
        case "searchResponse":
            let dataJson: JSON = json["data"]
            if let searchResponse = SearchResponse(json: dataJson) {
                received(response: searchResponse)
            }
        default:
            break
        }
    }
    
    // MARK: Private
    
    fileprivate func received(response: SearchResponse) {
        /*
        let res1 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "Rahul")
        let res2 = SearchViewData(photo: UIImage(named: "praful_test_pic"), text: "Praful")
        let res3 = SearchViewData(photo: UIImage(named: "reia_test_pic"), text: "Reia")
        */
    }
    
    fileprivate func searchForResults(_ searchText: String) {
        let searchRequest = SearchRequest(senderUuid: "", searchText: searchText)
        socketManager.send(json: searchRequest.toJSON())
    }
    
    fileprivate func configureSearch() {
        containerView?.searchTextField.startVisibleWithoutInteraction = true
        
        containerView?.searchTextField.itemSelectionHandler = { filteredResults, itemPosition  in
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
        
        containerView?.searchTextField.userStoppedTypingHandler = {
            if let searchText = self.containerView?.searchTextField.text {
                if searchText.characters.count > 0 {
                    self.containerView?.searchTextField.showLoadingIndicator()
                    self.searchForResults(searchText)
                }
            }
        }
    }
}
