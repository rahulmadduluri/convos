//
//  MainGroupInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyGif

class MainGroupInfoView: UIView, GroupInfoUIComponent, UITextFieldDelegate {
    
    fileprivate var flagIsWaving = false
    fileprivate var nameEditCancelButton = UIButton()
    fileprivate var memberEditCancelButton = UIButton()
    fileprivate var flagGifImageView = UIImageView()
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var nameTextField = UITextField()
    var memberTextField: SmartTextField = SmartTextField()
    var groupPhotoImageView = UIImageView()
    var createNewGroupButton = UIButton()
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
        nameTextField.font = nameTextField.font?.withSize(Constants.nameTextFieldFontSize)
        nameTextField.textAlignment = .center
        nameTextField.tag = Constants.nameTextFieldTag
        nameTextField.delegate = self
        nameTextField.alpha = flagIsWaving ? 0 : 1
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
        memberTextField.alpha = flagIsWaving ? 0 : 1
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
        createNewGroupButton.alpha = 0
        createNewGroupButton.addTarget(self, action: #selector(MainGroupInfoView.tapCreateNewGroup(_:)), for: .touchUpInside)
        self.addSubview(createNewGroupButton)
        
        // Member Table
        if let mTCV = memberTableContainerView {
            let flagIsWavingFrame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginYAdjusted, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeightAdjusted)
            let defaultFrame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginY, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeight)
            memberTableContainerView?.frame = flagIsWaving ? flagIsWavingFrame : defaultFrame
            mTCV.backgroundColor = UIColor.orange
            
            self.addSubview(mTCV)
        }
        
        let gif = UIImage(gifName: "flag_wave_2.gif")
        flagGifImageView.setGifImage(gif)
        flagGifImageView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY + groupPhotoImageView.frame.maxY, width: self.bounds.size.width, height: Constants.flagGifHeight)
        flagGifImageView.alpha = flagIsWaving ? 1 : 0
        self.addSubview(flagGifImageView)
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapNameEditCancel(_ obj: Any) {
        nameEditCancelButton.alpha = 0
        
        if (groupInfoVC?.isNewGroup ?? false) == true {
            nameTextField.text = ""
        } else {
            nameTextField.text = groupInfoVC?.getGroup()?.name
        }
        
        nameTextField.resignFirstResponder()
    }

    func tapMemberEditCancel(_ obj: Any) {
        memberEditCancelButton.alpha = 0
        
        // if group exists, go back to original name
        memberTextField.text = ""
        if (groupInfoVC?.isNewGroup ?? false) == false {
            groupInfoVC?.resetMembers()
        }
        
        memberTextField.resignFirstResponder()
    }
    
    func tapCreateNewGroup(_ obj: Any) {        
        groupInfoVC?.groupCreated(name: nameTextField.text, photo: groupPhotoImageView.image)
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
            nameEditCancelButton.alpha = 0
        } else if textField.tag == Constants.memberTextFieldTag {
            groupInfoVC?.memberSearchUpdated()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func resetFlag() {
        flagIsWaving = false
        nameTextField.text = ""
        memberTextField.text = ""
        setNeedsLayout()
    }
    
    func showFlag() {
        flagIsWaving = true
        
        nameTextField.alpha = 0
        memberTextField.alpha = 0
        createNewGroupButton.alpha = 0
        nameEditCancelButton.alpha = 0
        memberEditCancelButton.alpha = 0
        
        setNeedsLayout()
    }
    
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
    
    static let nameTextFieldPlaceholder: String = "Guild Name"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 60
    static let nameTextFieldFontSize: CGFloat = 24
    
    static let nameEditButtonOriginY: CGFloat = 196
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
    
    static let flagGifHeight: CGFloat = 300
    static let memberTableOriginYAdjusted: CGFloat = 450
    static let memberTableHeightAdjusted: CGFloat = 200
}

