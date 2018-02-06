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

class SearchViewController: UIViewController, SocketManagerDelegate, SearchComponentDelegate, SearchTextFieldDelegate {
    
    var searchVCDelegate: SearchVCDelegate? = nil

    fileprivate var containerView: MainSearchView? = nil
    // search results table
    fileprivate var searchTableVC = SearchTableViewController()
    // all group/conversations stored
    fileprivate var allCachedGroups = Set<Group>()
    // map of search view dat
    // key: group's default conversation
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
    
    // MARK: SearchComponentDelegate
    
    func getSearchViewData() -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        return searchViewData
    }
        
    func convoCreated(groupUUID: String) {
        for g in allCachedGroups {
            if g.uuid == groupUUID {
                searchVCDelegate?.convoCreated(group: g)
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
    
    func groupSelected(conversationUUID: String) {
        for g in allCachedGroups {
            for c in g.conversations {
                if c.uuid == conversationUUID {
                    searchVCDelegate?.groupSelected(group: g)
                }
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
    
    fileprivate func createSearchViewData(groups: Set<Group>) -> OrderedDictionary<SearchViewData, [SearchViewData]> {
        var viewDataMap = OrderedDictionary<SearchViewData, [SearchViewData]>()
        for g in groups {
            let defaultConvo = g.conversations.filter { $0.isDefault == true }.first
            let cs = g.conversations.sorted(by: >).filter { $0.isDefault == false }
            if let defaultConvo = defaultConvo {
                // see comment at top to understand data structure
                viewDataMap[SearchViewData(uuid: defaultConvo.uuid, text: defaultConvo.topic, photoURI: defaultConvo.photoURI, updatedTimestamp: defaultConvo.updatedTimestampServer, updatedTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: defaultConvo.updatedTimestampServer), type: SearchViewType.defaultConversation.rawValue)] =
                    cs.map { SearchViewData(uuid: $0.uuid, text: $0.topic, photoURI: $0.photoURI, updatedTimestamp: $0.updatedTimestampServer, updatedTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: $0.updatedTimestampServer), type: SearchViewType.conversation.rawValue) }
            }
        }
        return viewDataMap
    }
    
    fileprivate func configureSearch() {
        searchTableVC.searchVC = self
        containerView?.searchTextField.searchTextFieldDelegate = self
        socketManager.delegates.add(delegate: self)
        
        let myUUID = "uuid-1"
        let request = SearchRequest(senderUuid: myUUID, searchText: "")
        SearchAPI.search(searchRequest: request)

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
            for c in g.conversations {
                let topicFilterRange = (c.topic as NSString).range(of: text, options: [.caseInsensitive])
                if (topicFilterRange.location != NSNotFound) {
                    if let gCopy = g.copy() as? Group {
                        if !gCopy.conversations.contains(c) {
                            gCopy.conversations.append(c)
                        }
                        filteredGroups.insert(g)
                    }
                }
            }
        }
        searchViewData = createSearchViewData(groups: filteredGroups)
    }
    
    fileprivate func remoteSearch(searchText: String) {
        // replace with actual UUID
        let myUUID = "uuid-1"
        let request = SearchRequest(senderUuid: myUUID, searchText: searchText)
        SearchAPI.search(searchRequest: request)
    }
}
