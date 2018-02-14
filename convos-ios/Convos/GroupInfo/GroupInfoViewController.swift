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

class GroupInfoViewController: UIViewController, SmartTextFieldDelegate, GroupInfoComponentDelegate {
    
    var groupInfoVCDelegate: GroupInfoVCDelegate? = nil
    var userViewData: [UserViewData] = []
    
    // if group == nil, we are creating a new group
    fileprivate var group: Group? = nil
    fileprivate var people: [User] = []
    fileprivate var containerView: MainGroupInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    // group members table
    fileprivate var memberTableVC = MemberTableViewController()
    
    var memberSearchText: String? {
        return containerView?.memberTextField.text
    }
    
    var isEditingMembers: Bool {
        return containerView?.memberEditButton.state == .selected
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGroupInfo()
    }
    
    override func loadView() {
        self.addChildViewController(memberTableVC)
        
        containerView = MainGroupInfoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        if group == nil {
            containerView?.groupPhotoImageView.image = UIImage(named: "capybara")
        }
        containerView?.addGestureRecognizer(panGestureRecognizer)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        remoteSearch(memberText: memberSearchText ?? "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
    }
    
    
    // MARK: GroupInfoComponentDelegate
    
    func getGroup() -> Group? {
        return group
    }
    
    func getUserViewData() -> [UserViewData] {
        return userViewData
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
        containerView?.memberTextField.hasInteracted = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
    }
    
    // MARK: Public
    
    func setGroupInfo(group: Group?) {
        self.group = group
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            if (translation.x > 150) {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: Private
    
    fileprivate func configureGroupInfo() {
        containerView?.memberTextField.smartTextFieldDelegate = self
        memberTableVC.groupInfoVC = self
        memberTableVC.reloadMemberViewData()
        
        containerView?.memberTextField.userStoppedTypingHandler = {
            if let memberText = self.memberSearchText {
                if memberText.characters.count > 0 {
                    self.containerView?.memberTextField.showLoadingIndicator()
                    self.remoteSearch(memberText: memberText)
                }
            }
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func remoteSearch(memberText: String) {
        if let userUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = memberSearchText ?? ""
            let maxPeople = 20 // arbitrary upper bound
            if isEditingMembers == true {
                UserAPI.getPeople(userUUID: userUUID, searchText: searchText, maxPeople: maxPeople, completion: { people in
                    if let p = people {
                        self.received(people: p)
                    }
                })
            } else {
                // only grab group members if we're grabbing existing group members
                // NOTE: this will break when we try adding people to new group -- need to fix this
                if let groupUUID = group?.uuid {
                    UserAPI.getPeople(groupUUID: groupUUID, searchText: searchText, maxPeople: maxPeople, completion: { people in
                        if let p = people {
                            self.received(people: p)
                        }
                    })
                }
            }
        }
    }
    
    fileprivate func received(people: [User]) {
        userViewData = createUserViewData(people: people)
        memberTableVC.reloadMemberViewData()
        containerView?.memberTextField.stopLoadingIndicator()
    }
    
    fileprivate func createUserViewData(people: [User]) -> [UserViewData] {
        return people.map({ p -> UserViewData in
            return UserViewData(uuid: p.uuid, text: p.name, photoURI: p.photoURI)
        })
    }
}
