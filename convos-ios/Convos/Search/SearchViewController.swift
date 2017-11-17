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
    
    var filteredConversations: [Conversation] = []
    fileprivate var allCachedConversations: [String: Conversation] = [:]
    
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
                let viewData = SearchViewData(photo: nil, text: convo.title)
                groupViewDataMap[convo.groupUUID] = viewData
            }
        }
        
        // Add non-default conversations as children
        for convo in filteredConversations {
            if !convo.isDefault {
                if let _ = groupViewDataMap[convo.groupUUID] {
                    let viewData = SearchViewData(photo: nil, text: convo.title, isTopLevel: false)
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
            remoteSearch(searchText: searchText) // upon completion reload search results data
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
    
    func received(json: JSON) {
        switch json["type"].stringValue {
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
        if let conversations = response.conversations {
            for convo in conversations {
                allCachedConversations[convo.uuid] = convo
            }
        }
        containerView?.searchTextField.stopLoadingIndicator()
    }
    
    fileprivate func searchForResults(_ searchText: String) {
        let searchRequest = SearchRequest(senderUuid: "", searchText: searchText)
        socketManager.send(json: searchRequest.toJSON())
    }
    
    fileprivate func configureSearch() {
        searchTableVC.searchTableVCDelegate = self
        containerView?.searchTextField.searchTextFieldDelegate = self
        
        searchForResults("")
        
        allCachedConversations["1"] = Conversation(uuid: "1", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "", title: "Rahul", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["2"] = Conversation(uuid: "2", groupUUID: "2", updatedTimestampServer: 0, topicTagUUID: "", title: "Praful", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["3"] = Conversation(uuid: "3", groupUUID: "3", updatedTimestampServer: 0, topicTagUUID: "", title: "Reia", isDefault: true, groupPhotoURL: nil)
        allCachedConversations["4"] = Conversation(uuid: "4", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "", title: "#A", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["5"] = Conversation(uuid: "5", groupUUID: "2", updatedTimestampServer: 0, topicTagUUID: "", title: "#B", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["6"] = Conversation(uuid: "6", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "", title: "#C", isDefault: false, groupPhotoURL: nil)
        allCachedConversations["7"] = Conversation(uuid: "7", groupUUID: "3", updatedTimestampServer: 0, topicTagUUID: "", title: "#Scrub", isDefault: false, groupPhotoURL: nil)
        
        filteredConversations.removeAll()
        for c in allCachedConversations.values {
            filteredConversations.append(c)
        }
        searchTableVC.reloadSearchResultsData()
        
        containerView?.searchTextField.userStoppedTypingHandler = {
            if let searchText = self.containerView?.searchTextField.text {
                if searchText.characters.count > 0 {
                    self.containerView?.searchTextField.showLoadingIndicator()
                    self.searchForResults(searchText)
                }
            }
        }
    }
    
    fileprivate func localSearch(searchText: String) {
        filteredConversations.removeAll()
        
        var groupFoundMap: [String: Bool] = [:]
        
        for convo in allCachedConversations.values {
            let parentFilterRange = (convo.title as NSString).range(of: searchText, options: [.caseInsensitive])
            if parentFilterRange.location != NSNotFound {
                if !filteredConversations.contains(convo) {
                    filteredConversations.append(convo)
                }
                groupFoundMap[convo.groupUUID] = true
            }
        }
        
        for convo in allCachedConversations.values {
            if let _ = groupFoundMap[convo.groupUUID] {
                let childFilterRange = (convo.title as NSString).range(of: searchText, options: [.caseInsensitive])
                if childFilterRange.location != NSNotFound {
                    if !filteredConversations.contains(convo) {
                        filteredConversations.append(convo)
                    }
                }
            }
        }
    }
    
    fileprivate func remoteSearch(searchText: String) {
        let myUUID = ""
        let request = SearchRequest(senderUuid: myUUID, searchText: searchText)
        SearchAPI.search(searchRequest: request)
    }
}
