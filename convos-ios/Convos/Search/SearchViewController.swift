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

class SearchViewController: UIViewController, SocketManagerDelegate, SearchTableComponentDelegate, SearchTextFieldDelegate {
    
    var searchVCDelegate: SearchVCDelegate? = nil

    fileprivate var containerView: MainSearchView? = nil
    fileprivate var searchTableVC = SearchTableViewController() // search results table
    fileprivate var filteredGroups = Set<Group>() // filtered groups used for view data
    fileprivate var allCachedGroups = Set<Group>() // all group/conversations stored
    fileprivate var searchViewData = OrderedDictionary<SearchViewData, [SearchViewData]>()
    fileprivate let socketManager: SocketManager = SocketManager.sharedInstance
        
    var searchText: String? {
        return containerView?.searchTextField.text
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
    }
    
    override func loadView() {
        self.addChildViewController(searchTableVC)
        
        containerView = MainSearchView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
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
    
    // MARK: SearchTableComponentDelegate
    
    func getSearchViewData() -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        return searchViewData
    }
    
    func getSearchViewDataNonDefault() -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        var copySVD = getSearchViewData()
        for (g, cs) in copySVD.dict {
            copySVD[g] = cs.filter { $0.type == SearchViewType.conversation.rawValue }
        }
        return copySVD
    }
    
    func convoCreated(groupUUID: String) {
        for g in allCachedGroups {
            if g.uuid == groupUUID {
                searchVCDelegate?.convoCreated(group: g)
            }
        }
    }
    
    func convoSelected(uuid: String) {
        for g in filteredGroups {
            for c in g.conversations {
                if c.uuid == uuid {
                    searchVCDelegate?.convoSelected(conversation: c)
                }
            }
        }
    }
    
    func groupSelected(uuid: String) {
        for g in filteredGroups {
            if (g.uuid == uuid) {
                searchVCDelegate?.groupSelected(group: g)
            }
        }
    }
    
    // MARK: SearchTextFieldDelegate
    
    func searchTextUpdated(searchText text: String) {
        localSearch(text: text)
        searchTableVC.reloadSearchViewData()
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
                allCachedGroups.insert(g)
            }
        }
        let localSearchText = searchText ?? ""
        searchTextUpdated(searchText: localSearchText)
        containerView?.searchTextField.stopLoadingIndicator()
    }
    
    fileprivate func createSearchViewData() -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        var res = OrderedDictionary<SearchViewData, [SearchViewData]>()
        for g in filteredGroups {
            let cs = g.conversations.sorted(by: >)
            res[SearchViewData(uuid: g.uuid, text: g.name, photo: nil, updatedTimestamp: cs[0].updatedTimestampServer, updatedTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: cs[0].updatedTimestampServer), type: SearchViewType.group.rawValue)] =
                cs.map { SearchViewData(uuid: $0.uuid, text: $0.topic, photo: nil, updatedTimestamp: $0.updatedTimestampServer, updatedTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: $0.updatedTimestampServer), type: SearchViewType.conversation.rawValue) }
        }
        return res
    }
    
    fileprivate func configureSearch() {
        searchTableVC.searchVC = self
        containerView?.searchTextField.searchTextFieldDelegate = self
        socketManager.delegates.add(delegate: self)
        
        testingSetup()
        searchTableVC.reloadSearchViewData()
        
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
        
        if text.isEmpty {
            filteredGroups = allCachedGroups
        }
                
        // get matching groups
        for g in allCachedGroups {
            let groupFilterRange = (g.name as NSString).range(of: text, options: [.caseInsensitive])
            if (groupFilterRange.location != NSNotFound) {
                filteredGroups.insert(g)
            }
        }
        
        // get conversations with matching searchText (as long as their default group convo can be found)
        for g in allCachedGroups {
            for c in g.conversations {
                let topicFilterRange = (c.topic as NSString).range(of: text, options: [.caseInsensitive])
                if (topicFilterRange.location != NSNotFound) {
                    g.conversations.append(c)
                    filteredGroups.insert(g)
                }
            }
        }
        searchViewData = createSearchViewData()
    }
    
    fileprivate func remoteSearch(searchText: String) {
        // replace with actual UUID
        let myUUID = "uuid-1"
        let request = SearchRequest(senderUuid: myUUID, searchText: searchText)
        SearchAPI.search(searchRequest: request)
    }
    
    fileprivate func testingSetup() {
        let defaultconvo1 = Conversation(uuid: "1", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "1", topic: "Rahul", isDefault: true, photoURL: nil)
        let defaultconvo2 = Conversation(uuid: "2", groupUUID: "2", updatedTimestampServer: 0, topicTagUUID: "2", topic: "Praful", isDefault: true, photoURL: nil)
        let defaultconvo3 = Conversation(uuid: "3", groupUUID: "3", updatedTimestampServer: 0, topicTagUUID: "3", topic: "Reia", isDefault: true, photoURL: nil)
        
        // non-default
        let conversation1 = Conversation(uuid: "4", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "4", topic: "#A", isDefault: false, photoURL: nil)
        let conversation2 = Conversation(uuid: "5", groupUUID: "2", updatedTimestampServer: 0, topicTagUUID: "5", topic: "#B", isDefault: false, photoURL: nil)
        let conversation3 = Conversation(uuid: "6", groupUUID: "1", updatedTimestampServer: 0, topicTagUUID: "6", topic: "#C", isDefault: false, photoURL: nil)
        let conversation4 = Conversation(uuid: "7", groupUUID: "3", updatedTimestampServer: 0, topicTagUUID: "7", topic: "#Scrub", isDefault: false, photoURL: nil)
        
        let group1 = Group(uuid: "1", name: "Rahul", photoURL: nil, conversations: [defaultconvo1, conversation1, conversation3])
        let group2 = Group(uuid: "2", name: "Praful", photoURL: nil, conversations: [defaultconvo2, conversation2])
        let group3 = Group(uuid: "3", name: "Reia", photoURL: nil, conversations: [defaultconvo3, conversation4])
        
        filteredGroups.removeAll()
        allCachedGroups = [group1, group2, group3]
        searchTextUpdated(searchText: "")
    }
}
