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
    var allCachedResults: [SearchViewData] { get }
}

class SearchViewController: UIViewController, SocketManagerDelegate, SearchTableVCDelegate, SearchTextFieldDelegate {

    var containerView: MainSearchView? = nil
    var searchTableVC = SearchTableViewController() // search results table
    var searchVCDelegate: SearchVCDelegate? = nil
    
    let socketManager: SocketManager = SocketManager.sharedInstance
    
    var filteredResults: [SearchViewData] = []
    var allCachedResults: [SearchViewData] = []
        
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
            filteredResults = filter(searchText: searchText)
        }
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
    }
    
    fileprivate func searchForResults(_ searchText: String) {
        let searchRequest = SearchRequest(senderUuid: "", searchText: searchText)
        socketManager.send(json: searchRequest.toJSON())
    }
    
    fileprivate func configureSearch() {
        searchForResults("")
        
        // test
        let res1 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "Rahul")
        let res2 = SearchViewData(photo: UIImage(named: "praful_test_pic"), text: "Praful")
        let res3 = SearchViewData(photo: UIImage(named: "reia_test_pic"), text: "Reia")
        allCachedResults = [res1, res2, res3]
        
        containerView?.searchTextField.userStoppedTypingHandler = {
            if let searchText = self.containerView?.searchTextField.text {
                if searchText.characters.count > 0 {
                    self.containerView?.searchTextField.showLoadingIndicator()
                    self.searchForResults(searchText)
                }
            }
        }
    }
    
    fileprivate func filter(searchText: String) -> [SearchViewData] {
        /*
        fileprivate func filter(forceShowAll addAll: Bool) {
            if text!.characters.count < minCharactersNumberToStartFiltering {
                return
            }
            
            for i in 0 ..< filterDataSource.count {
                
                let item = filterDataSource[i]
                
                // Find text in title and subtitles
                let titleFilterRange = (item.title as NSString).range(of: text!, options: comparisonOptions)
                
                if titleFilterRange.location != NSNotFound || addAll {
                    item.attributedTitle = NSMutableAttributedString(string: item.title)
                    
                    for subtitle in item.subtitles {
                        let subtitleFilterRange = subtitle != nil ? (subtitle! as NSString).range(of: text!, options: comparisonOptions) : NSMakeRange(NSNotFound, 0)
                        
                        if subtitleFilterRange.location != NSNotFound {
                            let attributedSubtitle = NSMutableAttributedString(string: (subtitle != nil ? subtitle! : ""))
                            item.attributedSubtitles.append(attributedSubtitle)
                        }
                        
                    }
                    
                    filteredResults.append(item)
                }
            }
        }
        */
        return allCachedResults

    }
}
