//
//  GroupInfoViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftWebSocket

class GroupInfoViewController: UIViewController, SmartTextFieldDelegate {
    var groupInfoVCDelegate: GroupInfoVCDelegate? = nil
    
    fileprivate var containerView: MainGroupInfoView? = nil
    // group members table
    fileprivate var memberTableVC = GroupMemberTableViewController()
    
    var memberSearchText: String? {
        return containerView?.memberTextField.text
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGroupInfo()
    }
    
    override func loadView() {
        self.addChildViewController(memberTableVC)
        
        containerView = MainGroupInfoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.memberTableContainerView = memberTableVC.view
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
        containerView?.memberTextField.hasInteracted = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
    }
    
    // MARK: Private
    
    fileprivate func configureGroupInfo() {
        containerView?.memberTextField.smartTextFieldDelegate = self
        
        memberTableVC.reloadMemberViewData()
        
        containerView?.memberTextField.userStoppedTypingHandler = {
            if let memberText = self.containerView?.memberTextField.text {
                if memberText.characters.count > 0 {
                    self.containerView?.memberTextField.showLoadingIndicator()
                    self.remoteSearch(memberText: memberText) // upon completion reload search results data
                }
            }
        }
    }
    
    fileprivate func remoteSearch(memberText: String) {
        if let uuid = UserDefaults.standard.object(forKey: "uuid") as? String {
            //UserAPI.getUsers
        }
    }
}
