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

protocol SearchVCDelegate {
    func resultSelected(result: SearchViewData)
    func keyboardWillShow()
    func keyboardWillHide()
}

protocol SearchComponentDelegate {
    var filteredResults: [SearchViewData] { get set }
}

class SearchViewController: UIViewController, SocketManagerDelegate, SearchTableVCDelegate, SearchTextFieldDelegate {

    var containerView: MainSearchView? = nil
    var searchTableVC = SearchTableViewController() // search results table
    var searchVCDelegate: SearchVCDelegate? = nil
    
    let socketManager: SocketManager = SocketManager.sharedInstance
    
    var filteredResults: [SearchViewData] = []
    fileprivate var allCachedResults: [SearchViewData] = []
        
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
    
    // MARK: SearchTextFieldDelegate
    
    func searchTextUpdated(searchText: String) {
        if searchText.isEmpty {
            filteredResults = Array(allCachedResults.prefix(3))
        } else {
            localSearch(searchText: searchText)
            remoteSearch(searchText: searchText)
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
        // convert response into SearchViewData
        // append SearchViewData to All Cached Results
        // if there is a collision, replace cached result with search view
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
        
        // test
        var res1 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "Rahul", isCollapsed: false)
        var res2 = SearchViewData(photo: UIImage(named: "praful_test_pic"), text: "Praful", isCollapsed: false)
        var res3 = SearchViewData(photo: UIImage(named: "reia_test_pic"), text: "Reia", isCollapsed: false)
        let res4 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "#Amrendra", isTopLevel: false)
        let res5 = SearchViewData(photo: UIImage(named: "praful_test_pic"), text: "#Mahendra", isTopLevel: false)
        let res6 = SearchViewData(photo: UIImage(named: "reia_test_pic"), text: "#Scrub", isTopLevel: false)
        let res7 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "#BAHUBALI", isTopLevel: false)
        res1.children.append(res4)
        res1.children.append(res7)
        res2.children.append(res5)
        res3.children.append(res6)
        allCachedResults = [res1, res2, res3]
        filteredResults = allCachedResults
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
        filteredResults = []
        
        for p in allCachedResults {
            var parentResult = p // NOTE: When we separate view model from search response make this is a copy()
            
            var foundMatchInParent = false
            
            let parentFilterRange = (parentResult.text as NSString).range(of: searchText, options: [.caseInsensitive])
            if parentFilterRange.location != NSNotFound {
                foundMatchInParent = true
            }
            var matchedChildren: [SearchViewData] = []
            for c in parentResult.children {
                guard let childResult = c as? SearchViewData else {
                    continue
                }
                let childFilterRange = (childResult.text as NSString).range(of: searchText, options: [.caseInsensitive])
                if childFilterRange.location != NSNotFound {
                    matchedChildren.append(childResult)
                }
            }
            parentResult.children = matchedChildren
            
            if foundMatchInParent == true || parentResult.children.count > 0 {
                filteredResults.append(parentResult)
            }
        }
    }
    
    fileprivate func remoteSearch(searchText: String) {
        
    }
}
