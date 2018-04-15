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

class SearchViewController: UIViewController, SocketManagerDelegate, SearchComponentDelegate, SmartTextFieldDelegate {
    
    var searchVCDelegate: SearchVCDelegate? = nil

    fileprivate var containerView: MainSearchView? = nil
    // search results table
    fileprivate var searchTableVC = SearchTableViewController()
    // all group/conversations stored
    fileprivate var allCachedGroups = Set<Group>()
    // map of search view data
    // key: group
    // value: list of group's conversations
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
        containerView?.searchVC = self
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        remoteSearch(searchText: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
        containerView?.searchTextField.hasInteracted = true
    }
    
    func keyboardWillHide(_ notification: Notification) {

    }
        
    // MARK: SearchComponentDelegate
    
    func getSearchViewData() -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        return searchViewData
    }
    
    func getGroupForUUID(groupUUID: String) -> Group? {
        for g in allCachedGroups {
            if g.uuid == groupUUID {
                return g
            }
        }
        return nil
    }
    
    func createConvo(groupUUID: String) {
        for g in allCachedGroups {
            if g.uuid == groupUUID {
                searchVCDelegate?.createConvo(group: g)
            }
        }
    }
    
    func convoSelected(uuid: String) {
        for g in allCachedGroups {
            for c in g.conversations {
                if c.uuid == uuid {
                    searchVCDelegate?.convoSelected(conversation: c)
                }
            }
        }
    }
    
    func createGroup() {
        searchVCDelegate?.createGroup()
    }
    
    func groupSelected(groupUUID: String) {
        for g in allCachedGroups {
            if g.uuid == groupUUID {
                searchVCDelegate?.groupSelected(group: g)
            }
        }
    }
    
    func contactsSelected() {
        searchVCDelegate?.showContacts()
    }
    
    func profileSelected() {
        searchVCDelegate?.showProfile()
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
        localSearch(text: smartText)
        searchTableVC.reloadSearchViewData()
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
                if allCachedGroups.contains(g) {
                    allCachedGroups.remove(g)
                }
                allCachedGroups.insert(g)
            }
        }
        let localSearchText = searchText ?? ""
        smartTextUpdated(smartText: localSearchText)
        containerView?.searchTextField.stopLoadingIndicator()
    }
    
    fileprivate func createSearchViewData(groups: Set<Group>) -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        var viewDataMap = OrderedDictionary<SearchViewData, [SearchViewData]>()
        viewDataMap.isIncreasing = false
        for g in groups {
            let cs = g.conversations.sorted(by: >)
            // see comment at top to understand data structure
            viewDataMap[SearchViewData(uuid: g.uuid, text: g.name, photoURI: g.photoURI, updatedTimestamp: 0, updatedTimeText: "", type: SearchViewType.group.rawValue)] =
                cs.map { SearchViewData(uuid: $0.uuid, text: $0.topic, photoURI: $0.photoURI, updatedTimestamp: $0.updatedTimestampServer, updatedTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: $0.updatedTimestampServer), type: SearchViewType.conversation.rawValue) }
        }
        return viewDataMap
    }
    
    fileprivate func configureSearch() {        
        searchTableVC.searchVC = self
        containerView?.searchTextField.smartTextFieldDelegate = self
        containerView?.bottomBarView.searchVC = self
        socketManager.delegates.add(delegate: self)
        
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
        var filteredGroups = Set<Group>()
        
        if text.isEmpty {
            searchViewData = createSearchViewData(groups: allCachedGroups)
            return
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
            if let gCopy = g.copy() as? Group, !filteredGroups.contains(g) {
                var cs: [Conversation] = []
                for c in g.conversations {
                    let topicFilterRange = (c.topic as NSString).range(of: text, options: [.caseInsensitive])
                    // if conversation is matched add to list
                    if (topicFilterRange.location != NSNotFound) {
                        cs.append(c)
                    }
                }
                // if there's a convo match then the group needs to be added to results
                if cs.count > 0 {
                    gCopy.conversations = cs
                    filteredGroups.insert(gCopy)
                }
            }
        }
        searchViewData = createSearchViewData(groups: filteredGroups)
    }
    
    fileprivate func remoteSearch(searchText: String) {
        if let uuid = UserDefaults.standard.object(forKey: "uuid") as? String {
            let request = SearchRequest(senderUUID: uuid, searchText: searchText)
            SearchAPI.search(searchRequest: request)
        }
    }
}
