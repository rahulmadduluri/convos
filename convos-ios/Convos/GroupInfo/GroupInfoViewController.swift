//
//  GroupInfoViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupInfoViewController: UIViewController, SmartTextFieldDelegate, GroupInfoComponentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // if isNewGroup == true, GroupInfoVC is creating a new group
    
    var groupInfoVCDelegate: GroupInfoVCDelegate? = nil
    var memberViewData: [MemberViewData] = []

    fileprivate var group: Group? = nil
    // queue of removable members *while creating a new group*
    fileprivate var removableMemberViewDataQueue: [MemberViewData] = []
    fileprivate var containerView: MainGroupInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    fileprivate var imagePicker = UIImagePickerController()
    // group members table
    fileprivate var memberTableVC = MemberTableViewController()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureGroupInfo()
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
                    print("Failed to update group photo :( ")
                }
            }
        }
    }
    
    func groupNameEdited(name: String) {
        if isNewGroup == false {
            GroupAPI.updateGroup(groupUUID: group!.uuid, newGroupName: name, newMemberUUID: nil) { success in
                if success == false {
                    print("Failed to update group name :( ")
                } else {
                    self.group?.name = name
                }
            }
        }
    }
    
    func groupCreated(name: String?, photo: UIImage?) {
        memberTableVC.reloadMemberViewData()
        let memberUUIDs: [String] = removableMemberViewDataQueue.flatMap { $0.uuid }
        
        
        // wave flag for 2 seconds
        if let name = name,
            name.isEmpty == false,
            memberUUIDs.count > 0,
            isNewGroup == true {
            containerView?.showFlag()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2,  execute: {
                self.resetRemovableMemberQueue()
                self.containerView?.resetFlag()
                self.groupInfoVCDelegate?.groupCreated()
            })
            GroupAPI.createGroup(name: name, photo: photo, memberUUIDs: memberUUIDs) { success in
                if success == false {
                    print("Failed to encode create group request :( ")
                }
            }
        } else {
            let alert = UIAlertController(title: "Failed To Create Guild", message: "Missing Fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .destructive))
            present(alert, animated: true)
        }
    }
    
    func resetMembers() {
        resetRemovableMemberQueue()
        updateMembers()
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
            memberTableVC.reloadMemberViewData()
        // If existing group (and is a new member, add to group)
        } else if mvd.status == .memberNew && isNewGroup == false {
            let alert = UIAlertController(title: "New Guild Member", message: "Add " + mvd.text + " to the guild?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                // update group members
                GroupAPI.updateGroup(groupUUID: self.group!.uuid, newGroupName: nil, newMemberUUID: mvd.uuid, completion: { success in
                    if success == false {
                        print("Failed to update group members :( ")
                    } else {
                        self.containerView?.memberTextField.text = ""
                        self.resetMembers()
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
        resetTextFields()
        resetMembers()
        
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
        
        containerView?.memberTextField.userStoppedTypingHandler = {
            if let memberText = self.memberSearchText {
                if memberText.characters.count > 0 {
                    self.containerView?.memberTextField.showLoadingIndicator()
                    self.fetchPotentialMembers()
                } else {
                    self.containerView?.memberTextField.showLoadingIndicator()
                    self.updateMembers()
                }
            }
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func updateMembers() {
        if isNewGroup == true {
            memberViewData = removableMemberViewDataQueue
            self.containerView?.memberTextField.stopLoadingIndicator()
        } else {
            fetchGroupMembers()
        }
        memberTableVC.reloadMemberViewData()
    }
    
    fileprivate func fetchGroupMembers() {
        if isNewGroup == false {
            GroupAPI.getMembers(groupUUID: group!.uuid, searchText: "", maxMembers: nil, completion: { members in
                self.containerView?.memberTextField.stopLoadingIndicator()
                if let m = members {
                    self.receivedCurrentMembers(members: m)
                }
            })
        } else {
            self.receivedCurrentMembers(members: [])
        }
    }
    
    fileprivate func fetchPotentialMembers() {
        if let userUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = memberSearchText ?? ""
            UserAPI.getContacts(userUUID: userUUID, searchText: searchText, maxContacts: nil, completion: { allUsers in
                self.containerView?.memberTextField.stopLoadingIndicator()
                if let allUsers = allUsers {
                    self.receivedPotentialMembers(potentialMembers: allUsers)
                }
            })
        }
    }
    
    fileprivate func receivedCurrentMembers(members: [User]) {
        memberViewData = createMemberViewData(people: members)
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
    }
    
    fileprivate func createMemberViewData(people: [User], status: MemberViewStatus = .normal) -> [MemberViewData] {
        return people.map({ p -> MemberViewData in
            return MemberViewData(uuid: p.uuid, text: p.name, status: status, photoURI: p.photoURI)
        })
    }
    
    fileprivate func resetRemovableMemberQueue() {
        if let uuid = UserDefaults.standard.object(forKey: "uuid") as? String,
            let name = UserDefaults.standard.object(forKey: "name") as? String,
            let photoURI = UserDefaults.standard.object(forKey: "photo_uri") as? String {
            let myData = MemberViewData(uuid: uuid, text: name, status: .memberRemovable, photoURI: photoURI)
            self.removableMemberViewDataQueue = [myData]
        }
        self.containerView?.memberTextField.stopLoadingIndicator()
    }
    
    fileprivate func resetTextFields() {
        containerView?.memberTextField.text = ""
        containerView?.nameTextField.text = ""
    }
}

private struct Constants {
    static let nameTag = 1
    static let memberTag = 2
    static let photoTag = 3
}
