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


protocol SearchUIDelegate {
    func filteredViewData() -> [SearchViewData]
}

protocol SearchVCDelegate {
    func resultSelected(result: SearchViewData)
    func keyboardWillShow()
    func keyboardWillHide()
}

class SearchViewController: UIViewController, SocketManagerDelegate, SearchTableVCDelegate, SearchTextFieldDelegate {

    var containerView: MainSearchView? = nil
    var searchTableVC = SearchTableViewController() // search results table
    var searchVCDelegate: SearchVCDelegate? = nil
    
    let socketManager: SocketManager = SocketManager.sharedInstance
    
    var filteredConversations: [Conversation] = [] // filtered conversations used for view data
    fileprivate var allCachedConversations: [String: Conversation] = [:] // UUID: convo
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
    }
    
    override func loadView() {
        self.addChildViewController(searchTableVC)
        
        containerView = MainSearchView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 400))
        
        containerView?.searchTableContainerView = searchTableVC.view
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
        containerView?.searchTextField.hasInteracted = true
        searchVCDelegate?.keyboardWillShow()
    }
    
    func keyboardWillHide(_ notification: Notification) {
        searchVCDelegate?.keyboardWillHide()
    }
    
    func keyboardDidChangeFrame(_ notification: Notification) {
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.keyboardFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        }
        */
    }
    
    // MARK: SearchTableVCDelegate
    
    func itemSelected(viewData: CollapsibleTableViewData) {
        if let searchViewData = viewData as? SearchViewData {
            searchVCDelegate?.resultSelected(result: searchViewData)
        }
    }
    
    func filteredViewData() -> [SearchViewData] {
        var filteredViewData: [SearchViewData] = []
        var groupViewDataMap: [String: SearchViewData] = [:]
        
        // Add default conversations
        for convo in filteredConversations {
            if convo.isDefault {
                let viewData = SearchViewData(photo: nil, text: convo.groupName)
                groupViewDataMap[convo.groupUUID] = viewData
            }
        }
        
        // Add non-default conversations as children
        for convo in filteredConversations {
            if !convo.isDefault {
                if let _ = groupViewDataMap[convo.groupUUID] {
                    let viewData = SearchViewData(photo: nil, text: convo.topic, isTopLevel: false)
                    groupViewDataMap[convo.groupUUID]?.children.append(viewData)
                }
            }
        }
        
        for d in groupViewDataMap.values {
            filteredViewData.append(d)
        }
        return filteredViewData
    }
    
    // MARK: SearchTextFieldDelegate
    
    func searchTextUpdated(searchText: String) {
        if searchText.isEmpty {
            filteredConversations = Array(allCachedConversations.values.prefix(7))
        } else {
            localSearch(searchText: searchText)
        }
        searchTableVC.reloadSearchResultsData()
    }
    
    func keyboardWillShow() {
        searchVCDelegate?.keyboardWillShow()
    }
    
    func keyboardWillHide() {
        searchVCDelegate?.keyboardWillHide()
    }
    
    // MARK: SocketManagerDelegate
    
    func received(packet: Packet) {
        switch packet.type {
        case SearchAPI._searchResponse:
            if let searchResponse = SearchResponse(json: packet.data) {
                received(response: searchResponse)
            }
        default:
            break
        }
    }
    
    // MARK: Private
    
    fileprivate func received(response: SearchResponse) {
        if let conversations = response.conversations {
            for convo in conversations {
                allCachedConversations[convo.uuid] = convo
            }
        }
        let localSearchText = containerView?.searchTextField.text ?? ""
        searchTextUpdated(searchText: localSearchText)
        containerView?.searchTextField.stopLoadingIndicator()
    }
    
    fileprivate func configureSearch() {
        searchTableVC.searchTableVCDelegate = self
        containerView?.searchTextField.searchTextFieldDelegate = self
        socketManager.delegates.add(delegate: self)
        
        allCachedConversations["1"] = Conversation(uuid: "1", groupUUID: "1", groupName: "Rahul",  updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["2"] = Conversation(uuid: "2", groupUUID: "2", groupName: "Praful", updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["3"] = Conversation(uuid: "3", groupUUID: "3", groupName: "Reia", updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["4"] = Conversation(uuid: "4", groupUUID: "1", groupName: "Rahul", updatedTimestampServer: 0, topicTagUUID: "", topic: "#A", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["5"] = Conversation(uuid: "5", groupUUID: "2", groupName: "Praful", updatedTimestampServer: 0, topicTagUUID: "", topic: "#B", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["6"] = Conversation(uuid: "6", groupUUID: "1", groupName: "Rahul", updatedTimestampServer: 0, topicTagUUID: "", topic: "#C", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["7"] = Conversation(uuid: "7", groupUUID: "3", groupName: "Reia", updatedTimestampServer: 0, topicTagUUID: "", topic: "#Scrub", isDefault: false, groupPhotoURL: nil)
        
        filteredConversations.removeAll()
        for c in allCachedConversations.values {
            filteredConversations.append(c)
        }
        searchTableVC.reloadSearchResultsData()
        
        containerView?.searchTextField.userStoppedTypingHandler = {
            if let searchText = self.containerView?.searchTextField.text {
                if searchText.characters.count > 0 {
                    self.containerView?.searchTextField.showLoadingIndicator()
                    self.remoteSearch(searchText: searchText) // upon completion reload search results data
                }
            }
        }
    }
    
    fileprivate func localSearch(searchText: String) {
        filteredConversations.removeAll()
        
        var groupFoundMap: [String: Bool] = [:]
        
        // get conversations with matching group name
        for c in allCachedConversations.values {
            groupFoundMap[c.groupUUID] = true
            let groupFilterRange = (c.groupName as NSString).range(of: searchText, options: [.caseInsensitive])
            if (c.isDefault && groupFilterRange.location != NSNotFound) {
                if !filteredConversations.contains(c) {
                    filteredConversations.append(c)
                }
            }
        }
        
        // get conversations with matching searchText (as long as their default group convo can be found)
        for c in allCachedConversations.values {
            let topicFilterRange = (c.topic as NSString).range(of: searchText, options: [.caseInsensitive])
            if (topicFilterRange.location != NSNotFound && groupFoundMap[c.groupUUID] == true) {
                if !filteredConversations.contains(c) {
                    filteredConversations.append(c)
                }
            }
        }
    }
    
    fileprivate func remoteSearch(searchText: String) {
        // replace with actual UUID
        let myUUID = "uuid-1"
        let request = SearchRequest(senderUuid: myUUID, searchText: searchText)
        SearchAPI.search(searchRequest: request)
    }
}
