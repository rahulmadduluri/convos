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

class SearchViewController: UIViewController, SocketManagerDelegate, SearchUIDelegate, SearchTextFieldDelegate {

    var containerView: MainSearchView? = nil
    var searchTableVC = SearchTableViewController() // search results table
    var searchVCDelegate: SearchVCDelegate? = nil
    var filteredGroups = OrderedDictionary<Group, [Conversation]>() // filtered conversations used for view data
    
    let socketManager: SocketManager = SocketManager.sharedInstance
    
    
    var searchViewData: OrderedDictionary<SearchViewData, [SearchViewData]> {
        var res = OrderedDictionary<SearchViewData, [SearchViewData]>()
        for g in filteredGroups.keys {
            res[SearchViewData(uuid: g.uuid, text: g.name, photo: nil, type: SearchViewType.group.rawValue)] =
                cs.map { SearchViewData(uuid: $0.uuid, text: $0.topic, photo: nil, type: SearchViewType.conversation.rawValue) }
        }
        return res
    }
    
    var searchText: String? {
        return containerView?.searchTextField.text
    }

    
    fileprivate var allCachedGroups: [Group: [Conversation]] = [:] // all group/conversations stored
    
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
    
    // MARK: SearchUIDelegate
    
    func convoSelected(uuid: String) {
        for (_, cs) in filteredGroups {
            for c in cs {
                if c.uuid == uuid {
                    searchVCDelegate?.convoSelected(conversation: c)
                }
            }
        }
    }
    
    func groupSelected(uuid: String) {
        for g in filteredGroups.keys {
            if (g.uuid == uuid) {
                searchVCDelegate?.groupSelected(group: g)
            }
        }
    }
    
    // MARK: SearchTextFieldDelegate
    
    func searchTextUpdated(text: String) {
        if text.isEmpty {
            let mra = mostRecentlyActiveGroups(allGroups: allCachedGroups, lastX: 7)
            
            filteredGroups =
                mostRecentlyActiveGroups(allGroups: allCachedGroups, lastX: 7)
        } else {
            localSearch(text: text)
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
        if let groups = response.groups {
            for g in groups {
                if allCachedGroups[g] == nil {
                    allCachedGroups[g] = []
                }
                for c in g.conversations {
                    allCachedGroups[g]?.append(c)
                }
            }
        }
        let localSearchText = searchText ?? ""
        searchTextUpdated(searchText: localSearchText)
        containerView?.searchTextField.stopLoadingIndicator()
    }
    
    fileprivate func configureSearch() {
        searchTableVC.searchVC = self
        containerView?.searchTextField.searchTextFieldDelegate = self
        socketManager.delegates.add(delegate: self)
        
        allCachedGroups["1"] = Conversation(uuid: "1", groupUUID: "1", groupName: "Rahul",  updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedGroups["2"] = Conversation(uuid: "2", groupUUID: "2", groupName: "Praful", updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedGroups["3"] = Conversation(uuid: "3", groupUUID: "3", groupName: "Reia", updatedTimestampServer: 0, topicTagUUID: "", topic: "", isDefault: true, groupPhotoURL: nil)
        allCachedGroups["1"] = Conversation(uuid: "4", groupUUID: "1", groupName: "Rahul", updatedTimestampServer: 0, topicTagUUID: "", topic: "#A", isDefault: false, groupPhotoURL: nil)
        allCachedGroups["2"] = Conversation(uuid: "5", groupUUID: "2", groupName: "Praful", updatedTimestampServer: 0, topicTagUUID: "", topic: "#B", isDefault: false, groupPhotoURL: nil)
        allCachedGroups["1"] = Conversation(uuid: "6", groupUUID: "1", groupName: "Rahul", updatedTimestampServer: 0, topicTagUUID: "", topic: "#C", isDefault: false, groupPhotoURL: nil)
        allCachedGroups["3"] = Conversation(uuid: "7", groupUUID: "3", groupName: "Reia", updatedTimestampServer: 0, topicTagUUID: "", topic: "#Scrub", isDefault: false, groupPhotoURL: nil)
        
        filteredGroups.removeAll()
        for c in allCachedGroups.values {
            filteredGroups.append(c)
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
    
    fileprivate func localSearch(text: String) {
        filteredGroups.removeAll()
        
        var groupMatched: [String: Bool] = [] // Did group name match?
        
        // get matching groups
        for g in allCachedGroups.keys {
            let groupFilterRange = (g.name as NSString).range(of: text, options: [.caseInsensitive])
            if (groupFilterRange.location != NSNotFound) {
                filteredGroups[g] = []
            }
        }
        
        // get conversations with matching searchText (as long as their default group convo can be found)
        for c in allCachedGroups.values {
            let topicFilterRange = (c.topic as NSString).range(of: text, options: [.caseInsensitive])
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
    
    fileprivate func mostRecentlyActiveGroups(groupConvoMap: [Group: [Conversation]], lastX: Int) -> [Group] {
        var activeGroups: [Group] = []
        let sortedConvos = groupConvoMap.values.flatMap{$0}.sorted{$0.updatedTimestampServer > $1.updatedTimestampServer}
        for c in sortedConvos {
            if (activeGroups.first{ $0.uuid == c.groupUUID } == nil) {
                if let g = groupConvoMap.keys.first(where: { $0.uuid == c.groupUUID }) {
                    activeGroups.append(g)
                }
            }
            if (activeGroups.count > lastX) {
                break
            }
        }
        return activeGroups
    }
}

private extension Group: Comparable {}
