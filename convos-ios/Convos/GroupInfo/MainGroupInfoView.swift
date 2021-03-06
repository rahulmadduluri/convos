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
    fileprivate var flagGifImageView = UIImageView()
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var nameTextField = UITextField()
    var handleTextField = UITextField()
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
        groupPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainGroupInfoView.tapGroupPhoto(_:)))
        singleTap.numberOfTapsRequired = 1
        groupPhotoImageView.addGestureRecognizer(singleTap)
        self.addSubview(groupPhotoImageView)
        
        // HandleTextField
        handleTextField.placeholder = Constants.handleTextFieldPlaceholder
        handleTextField.frame = CGRect(x: self.bounds.midX - Constants.handleTextFieldWidth/2, y: self.bounds.minY + Constants.handleTextFieldOriginY, width: Constants.handleTextFieldWidth, height: Constants.handleTextFieldHeight)
        handleTextField.font = handleTextField.font?.withSize(Constants.handleTextFieldFontSize)
        handleTextField.textAlignment = .center
        handleTextField.tag = Constants.handleTextFieldTag
        handleTextField.alpha = 1
        handleTextField.delegate = self
        self.addSubview(handleTextField)
        
        // MemberTextField
        memberTextField.defaultPlaceholderText = Constants.memberTextFieldPlaceholder
        memberTextField.frame = CGRect(x: self.bounds.midX - Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberTextFieldOriginY, width: Constants.memberTextFieldWidth, height: Constants.memberTextFieldHeight)
        memberTextField.textAlignment = .center
        memberTextField.tag = Constants.memberTextFieldTag
        memberTextField.delegate = self
        memberTextField.alpha = flagIsWaving ? 0 : 1
        self.addSubview(memberTextField)
        
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
            
            self.addSubview(mTCV)
        }
        
        let gif = UIImage(gifName: "flag_wave_2.gif")
        flagGifImageView.setGifImage(gif)
        flagGifImageView.frame = CGRect(x: self.bounds.minX + Constants.flagGifMargin, y: self.bounds.minY + groupPhotoImageView.frame.maxY, width: self.bounds.width - Constants.flagGifMargin*2, height: Constants.flagGifHeight)
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
    
    func tapGroupPhoto(_ obj: Any) {
        groupInfoVC?.presentAlertOption(tag: groupPhotoImageView.tag)
    }
    
    func tapCreateNewGroup(_ obj: Any) {        
        groupInfoVC?.groupCreated(name: nameTextField.text, handle: handleTextField.text, photo: groupPhotoImageView.image)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let t = textField.text, textField.tag == Constants.nameTextFieldTag {
            groupInfoVC?.groupNameEdited(name: t)
        }
        nameEditCancelButton.alpha = 0
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editAlertHasBeenPressed == true {
            editAlertHasBeenPressed = false
            return true
        } else {
            groupInfoVC?.presentAlertOption(tag: textField.tag)
            return false
        }
    }
    
    // MARK: Public
    
    func resetFlag() {
        flagIsWaving = false
        nameTextField.text = ""
        handleTextField.text = ""
        memberTextField.text = ""
        setNeedsLayout()
    }
    
    func showFlag() {
        flagIsWaving = true
        
        nameTextField.alpha = 0
        memberTextField.alpha = 0
        createNewGroupButton.alpha = 0
        nameEditCancelButton.alpha = 0
        
        setNeedsLayout()
    }
    
    func beginEditPressed(tag: Int) {
        editAlertHasBeenPressed = true
        if tag == Constants.nameTextFieldTag {
            nameEditCancelButton.alpha = 1
            nameTextField.becomeFirstResponder()
        } else if tag == Constants.memberTextFieldTag {
            memberTextField.becomeFirstResponder()
        } else if tag == Constants.groupPhotoTag {
            
        } else if tag == Constants.handleTextFieldTag {
            handleTextField.becomeFirstResponder()
        }
    }
    
}

private struct Constants {
    static let groupPhotoOriginY: CGFloat = 75
    static let groupPhotoRadius: CGFloat = 80
    static let groupImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldPlaceholder: String = "Name Your Guild"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 200
    static let nameTextFieldHeight: CGFloat = 40
    static let nameTextFieldFontSize: CGFloat = 24
    
    static let handleTextFieldPlaceholder: String = "@guildhandle"
    static let handleTextFieldOriginY: CGFloat = 210
    static let handleTextFieldWidth: CGFloat = 200
    static let handleTextFieldHeight: CGFloat = 40
    static let handleTextFieldFontSize: CGFloat = 16
    
    static let nameEditButtonOriginY: CGFloat = 196
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let memberTextFieldPlaceholder: String = "Add Members"
    static let memberTextFieldOriginY: CGFloat = 275
    static let memberTextFieldWidth: CGFloat = 200
    static let memberTextFieldHeight: CGFloat = 40
    
    static let memberTableMarginConstant: CGFloat = 25
    static let memberTableOriginY: CGFloat = 320
    static let memberTableHeight: CGFloat = 275
    
    static let createGroupButtonOriginY: CGFloat = 600
    static let createGroupButtonRadius: CGFloat = 40
    
    static let nameTextFieldTag: Int = 1
    static let memberTextFieldTag: Int = 2
    static let groupPhotoTag: Int = 3
    static let handleTextFieldTag: Int = 4
    
    static let flagGifHeight: CGFloat = 300
    static let flagGifMargin: CGFloat = 75
    static let memberTableOriginYAdjusted: CGFloat = 450
    static let memberTableHeightAdjusted: CGFloat = 200
}

