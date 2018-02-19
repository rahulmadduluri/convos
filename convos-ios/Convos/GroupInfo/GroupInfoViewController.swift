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

class GroupInfoViewController: UIViewController, SmartTextFieldDelegate, GroupInfoComponentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // if isNewGroup == true, GroupInfoVC is creating a new group
    
    var groupInfoVCDelegate: GroupInfoVCDelegate? = nil
    var memberViewData: [MemberViewData] = []

    fileprivate var group: Group? = nil
    fileprivate var people: [User] = []
    fileprivate var containerView: MainGroupInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    fileprivate var imagePicker = UIImagePickerController()
    // group members table
    fileprivate var memberTableVC = MemberTableViewController()
    // queue of removable members *while creating a new group*
    fileprivate var removableMemberViewDataQueue: [MemberViewData] = []
    
    var memberSearchText: String? {
        return containerView?.memberTextField.text
    }
    var isNewGroup: Bool {
        return group == nil
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        self.addChildViewController(memberTableVC)
        
        containerView = MainGroupInfoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

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
        configureGroupInfo()
        fetchGroupMembers()
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
    
    func getMemberViewData() -> [MemberViewData] {
        return memberViewData
    }
    
    func groupPhotoEdited(image: UIImage) {
        if isNewGroup == false{
            GroupAPI.updateGroupPhoto(groupUUID: group!.uuid, photo: image) { success in
                if success == false {
                    print("Failed to update group :( ")
                }
            }
        }
    }
    
    func groupNameEdited(name: String) {
        if isNewGroup == false {
            GroupAPI.updateGroup(groupUUID: group!.uuid, newGroupName: name, newMemberUUID: nil) { success in
                if success == false {
                    print("Failed to update group :( ")
                } else {
                    self.group?.name = name
                }
            }
        }
    }
    
    func groupCreated(name: String, photo: UIImage?) {
        if isNewGroup == true {
            let memberUUIDs: [String] = removableMemberViewDataQueue.flatMap { $0.uuid }
            // create group w/ name, memberUUIDs, and photo
            memberTableVC.reloadMemberViewData()
        }
    }
    
    func memberSearchUpdated() {
        self.containerView?.memberTextField.showLoadingIndicator()
        fetchPotentialMembers()
    }
        
    func resetMembers() {
        removableMemberViewDataQueue = []
        fetchGroupMembers()
    }
    
    func memberStatusSelected(mvd: MemberViewData) {
        // If creating new group (status should always be removable)
        if mvd.status == .memberRemovable && isNewGroup == true {
            removableMemberViewDataQueue = removableMemberViewDataQueue.filter { $0.uuid != mvd.uuid }
            memberViewData = removableMemberViewDataQueue
            memberTableVC.reloadMemberViewData()
        // if new group, set status to removable and add to list
        } else if mvd.status == .memberNew && isNewGroup == true {
            var removableMVD = mvd
            removableMVD.status = .memberRemovable
            // only add user to removable queue if it's not already there
            if !removableMemberViewDataQueue.contains(where: { $0.uuid == mvd.uuid }) {
                removableMemberViewDataQueue.append(removableMVD)
            }
            memberViewData = removableMemberViewDataQueue
            containerView?.memberTextField.text = ""
            containerView?.hideMemberCancel()
            memberTableVC.reloadMemberViewData()
        // If existing group (and is a new member, add to group)
        } else if mvd.status == .memberNew && isNewGroup == false {
            let alert = UIAlertController(title: "New Guild Member", message: "Add " + mvd.text + " to the guild?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                GroupAPI.updateGroup(groupUUID: self.group!.uuid, newGroupName: nil, newMemberUUID: mvd.uuid, completion: { success in
                    if success == false {
                        print("Failed to update group :( ")
                    } else {
                        self.containerView?.tapMemberEditCancel("")
                    }
                })
            })
            alert.addAction(UIAlertAction(title: "No", style: .destructive))
            present(alert, animated: true)
        }
    }
    
    func presentAlertOption(tag: Int) {
        var editActionTitle: String = ""
        let groupName = group?.name ?? "New Guild"
        let alert = UIAlertController(title: groupName, message: "", preferredStyle: .actionSheet)
        if tag == Constants.nameTag {
            editActionTitle += "Edit Name"
        } else if tag == Constants.memberTag {
            editActionTitle += "Add Member"
        } else if tag == Constants.photoTag {
            editActionTitle += "Edit Photo"
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
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            containerView?.groupPhotoImageView.image = chosenImage
            // make edit photo request
        }
        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        }
        
        if isNewGroup == false {
            containerView?.nameTextField.text = group!.name
            if let uri = group!.photoURI {
                containerView?.groupPhotoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
        } else {
            containerView?.groupPhotoImageView.image = UIImage(named: "capybara")
            containerView?.createNewGroupButton.alpha = 1
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func fetchGroupMembers() {
        if isNewGroup == false {
            GroupAPI.getPeople(groupUUID: group!.uuid, searchText: "", maxPeople: nil, completion: { people in
                if let p = people {
                    self.receivedCurrentMembers(people: p)
                }
            })
        } else {
            self.receivedCurrentMembers(people: [])
        }
    }
    
    fileprivate func fetchPotentialMembers() {
        if let userUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = memberSearchText ?? ""
            UserAPI.getPeople(userUUID: userUUID, searchText: searchText, maxPeople: nil, completion: { allUsers in
                if let allUsers = allUsers {
                    self.receivedPotentialMembers(potentialMembers: allUsers)
                }
            })
        }
    }
    
    fileprivate func receivedCurrentMembers(people: [User]) {
        memberViewData = createMemberViewData(people: people)
        memberTableVC.reloadMemberViewData()
        containerView?.memberTextField.stopLoadingIndicator()
    }
    
    // Get all potential members, and separate them into old & new
    fileprivate func receivedPotentialMembers(potentialMembers: [User]) {
        var allMemberViewData = createMemberViewData(people: potentialMembers, status: .memberNew)
        if isNewGroup == false {
            for mvd in allMemberViewData {
                // if existing memberViewData matches (current group overlaps w/ potential member)
                if var matchingMember = memberViewData.filter({ $0.uuid == mvd.uuid }).first {
                    // update status of view data to memberExists
                    allMemberViewData = allMemberViewData.filter{ $0.uuid != mvd.uuid }
                    matchingMember.status = .memberExists
                    allMemberViewData.append(matchingMember)
                }
            }
            memberViewData = allMemberViewData
        } else {
            memberViewData = allMemberViewData
        }
        memberTableVC.reloadMemberViewData()
        containerView?.memberTextField.stopLoadingIndicator()
    }
    
    fileprivate func createMemberViewData(people: [User], status: MemberViewStatus = .normal) -> [MemberViewData] {
        return people.map({ p -> MemberViewData in
            return MemberViewData(uuid: p.uuid, text: p.name, status: status, photoURI: p.photoURI)
        })
    }
}

private struct Constants {
    static let nameTag = 1
    static let memberTag = 2
    static let photoTag = 3
}
