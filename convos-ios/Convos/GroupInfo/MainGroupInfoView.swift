//
//  MainGroupInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainGroupInfoView: UIView, GroupInfoUIComponent, UITextFieldDelegate {
    
    fileprivate var nameEditCancelButton = UIButton()
    fileprivate var memberEditCancelButton = UIButton()
    fileprivate var createNewGroupButton = UIButton()
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var nameTextField = UITextField()
    var memberTextField: SmartTextField = SmartTextField()
    var groupPhotoImageView = UIImageView()
    var memberTableContainerView: UIView? = nil
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // NameTextField
        nameTextField.placeholder = Constants.nameTextFieldPlaceholder
        nameTextField.frame = CGRect(x: self.bounds.midX - Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameTextFieldOriginY, width: Constants.nameTextFieldWidth, height: Constants.nameTextFieldHeight)
        nameTextField.textAlignment = .center
        nameTextField.tag = Constants.nameTextFieldTag
        nameTextField.delegate = self
        self.addSubview(nameTextField)
        
        // NameEditCancelButton
        nameEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        nameEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        nameEditCancelButton.alpha = 0
        nameEditCancelButton.addTarget(self, action: #selector(MainGroupInfoView.tapNameEditCancel(_:)), for: .touchUpInside)
        self.addSubview(nameEditCancelButton)
        
        // configure image view
        groupPhotoImageView.frame = CGRect(x: self.bounds.midX - Constants.groupPhotoRadius/2, y: self.bounds.minY + Constants.groupPhotoOriginY, width: Constants.groupPhotoRadius, height: Constants.groupPhotoRadius)
        groupPhotoImageView.layer.cornerRadius = Constants.groupImageCornerRadius
        groupPhotoImageView.layer.masksToBounds = true
        groupPhotoImageView.tag = Constants.groupPhotoTag
        self.addSubview(groupPhotoImageView)
        
        // MemberTextField
        memberTextField.defaultPlaceholderText = Constants.memberTextFieldPlaceholder
        memberTextField.frame = CGRect(x: self.bounds.midX - Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberTextFieldOriginY, width: Constants.memberTextFieldWidth, height: Constants.memberTextFieldHeight)
        memberTextField.textAlignment = .center
        memberTextField.tag = Constants.memberTextFieldTag
        memberTextField.delegate = self
        self.addSubview(memberTextField)
        
        // MemberEditCancelButton
        memberEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        memberEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        memberEditCancelButton.alpha = 0
        memberEditCancelButton.addTarget(self, action: #selector(MainGroupInfoView.tapMemberEditCancel(_:)), for: .touchUpInside)
        self.addSubview(memberEditCancelButton)
        
        // CreateNewGroupButton
        createNewGroupButton.frame = CGRect(x: self.bounds.midX - Constants.createGroupButtonRadius/2, y: self.bounds.minY + Constants.createGroupButtonOriginY, width: Constants.createGroupButtonRadius, height: Constants.createGroupButtonRadius)
        createNewGroupButton.setImage(UIImage(named: "rocket_launch"), for: .normal)
        createNewGroupButton.alpha = groupInfoVC?.getGroup() != nil ? 0 : 1
        createNewGroupButton.addTarget(self, action: #selector(MainGroupInfoView.tapCreateNewGroup(_:)), for: .touchUpInside)
        self.addSubview(createNewGroupButton)
        
        // Member Table
        if let mTCV = memberTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginY, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeight)
            mTCV.backgroundColor = UIColor.orange
            
            self.addSubview(mTCV)
        }
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapNameEditCancel(_ gestureRecognizer: UITapGestureRecognizer) {
        nameEditCancelButton.alpha = 0
        
        if let g = groupInfoVC?.getGroup() {
            nameTextField.text = g.name
        } else {
            nameTextField.text = ""
        }
        
        nameTextField.resignFirstResponder()
    }

    func tapMemberEditCancel(_ gestureRecognizer: UITapGestureRecognizer) {
        memberEditCancelButton.alpha = 0
        
        // if group exists, go back to original name
        memberTextField.text = ""
        groupInfoVC?.resetMembers()
        
        memberTextField.resignFirstResponder()
    }
    
    func tapCreateNewGroup(_ gestureRecognizer: UITapGestureRecognizer) {
        if let name = nameTextField.text {
            groupInfoVC?.groupCreated(name: name, photo: groupPhotoImageView.image)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editAlertHasBeenPressed == true {
            editAlertHasBeenPressed = false
            return true
        } else {
            groupInfoVC?.presentAlertOption(tag: textField.tag)
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if textField.tag == Constants.nameTextFieldTag {
            groupInfoVC?.groupNameEdited(name: text)
        } else if textField.tag == Constants.memberTextFieldTag {
            groupInfoVC?.memberSearchUpdated()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func beginEditPressed(tag: Int) {
        editAlertHasBeenPressed = true
        if tag == Constants.nameTextFieldTag {
            nameEditCancelButton.alpha = 1
            nameTextField.becomeFirstResponder()
        } else if tag == Constants.memberTextFieldTag {
            memberEditCancelButton.alpha = 1
            memberTextField.becomeFirstResponder()
        } else if tag == Constants.groupPhotoTag {
            
        }
    }
    
    func hideMemberCancel() {
        memberEditCancelButton.alpha = 0
    }
    
}

private struct Constants {
    static let groupPhotoOriginY: CGFloat = 75
    static let groupPhotoRadius: CGFloat = 80
    static let groupImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldPlaceholder: String = "Group Name"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 40
    
    static let nameEditButtonOriginY: CGFloat = 186
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let memberTextFieldPlaceholder: String = "Members"
    static let memberTextFieldOriginY: CGFloat = 250
    static let memberTextFieldWidth: CGFloat = 150
    static let memberTextFieldHeight: CGFloat = 40
    
    static let memberEditButtonOriginY: CGFloat = 261
    
    static let memberTableMarginConstant: CGFloat = 25
    static let memberTableOriginY: CGFloat = 300
    static let memberTableHeight: CGFloat = 275
    
    static let createGroupButtonOriginY: CGFloat = 600
    static let createGroupButtonRadius: CGFloat = 40
    
    static let nameTextFieldTag: Int = 1
    static let memberTextFieldTag: Int = 2
    static let groupPhotoTag: Int = 3
}

