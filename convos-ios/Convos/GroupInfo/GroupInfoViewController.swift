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
    
    // if isNewGroup == true, GroupInfoVC is creating a new group
    
    var groupInfoVCDelegate: GroupInfoVCDelegate? = nil
    var userViewData: [UserViewData] = []
    
    fileprivate var group: Group? = nil
    fileprivate var people: [User] = []
    fileprivate var containerView: MainGroupInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    // group members table
    fileprivate var memberTableVC = MemberTableViewController()
    
    var isEditingMembers: Bool = false
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

        if isNewGroup() == true {
            containerView?.groupPhotoImageView.image = UIImage(named: "capybara")
        }
        containerView?.addGestureRecognizer(panGestureRecognizer)
        
        containerView?.groupInfoVC = self
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
    
    func groupNameEdited(name: String) {
        if isNewGroup() == false {
            // send request to edit name
        }
    }
    
    func groupMembersEdited() {
        if isNewGroup() == false {
            let memberUUIDs: [String] = userViewData.flatMap { $0.uuid }
            // 1. send request to edit members
            // 2. on completion make this call:
            let searchText = memberSearchText ?? ""
            UserAPI.getPeople(groupUUID: group!.uuid, searchText: searchText, maxPeople: Constants.maxPeople, completion: { people in
                if let p = people {
                    self.received(people: p)
                }
            })
        }
    }
    
    func groupCreated(name: String, photo: UIImage?) {
        if isNewGroup() == true {
            let memberUUIDs: [String] = userViewData.flatMap { $0.uuid }
            // create group w/ name, memberUUIDs, and photo
            memberTableVC.reloadMemberViewData()
        }
    }
    
    func presentAlertOption(tag: Int) {
        var editActionTitle: String = "Edit"
        let groupName = group?.name ?? ""
        let alert = UIAlertController(title: groupName, message: "", preferredStyle: .actionSheet)
        if tag == Constants.nameTag {
            editActionTitle += " Name"
        } else if tag == Constants.memberTag {
            alert.addAction(UIAlertAction(title: "Search Group", style: .default) { action in
            })
            editActionTitle += " Members"
        }
        alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
            self.containerView?.beginEditPressed(tag: tag)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
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
            // if editing, grab user's contacts, otherwise grab group members
            if searchText.isEmpty == false {
                UserAPI.getPeople(userUUID: userUUID, searchText: searchText, maxPeople: Constants.maxPeople, completion: { people in
                    if let p = people {
                        self.received(people: p)
                    }
                })
            } else if isNewGroup() == false {
                UserAPI.getPeople(groupUUID: group!.uuid, searchText: searchText, maxPeople: Constants.maxPeople, completion: { people in
                    if let p = people {
                        self.received(people: p)
                    }
                })
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
    
    fileprivate func isNewGroup() -> Bool {
        return group == nil
    }
}

private struct Constants {
    static let maxPeople = 20
    static let nameTag = 1
    static let memberTag = 2
}
