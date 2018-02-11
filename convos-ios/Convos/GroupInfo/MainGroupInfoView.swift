//
//  MainGroupInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainGroupInfoView: UIView, GroupInfoUIComponent, UITextFieldDelegate {
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var groupPhotoImageView = UIImageView()
    var nameEditButton = UIButton()
    var nameTextField = UITextField()
    var memberTextField: SmartTextField = SmartTextField()
    var memberEditButton = UIButton()
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
        
        // MemberTextField
        nameTextField.placeholder = Constants.nameTextFieldPlaceholder
        nameTextField.isUserInteractionEnabled = false
        nameTextField.frame = CGRect(x: self.bounds.midX - Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameTextFieldOriginY, width: Constants.nameTextFieldWidth, height: Constants.nameTextFieldHeight)
        nameTextField.textAlignment = .center
        nameTextField.delegate = self
        self.addSubview(nameTextField)
        
        // NameEditButton
        nameEditButton.frame = CGRect(x: self.bounds.midX + Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        nameEditButton.setImage(UIImage(named: "edit"), for: .normal)
        nameEditButton.alpha = Constants.editButtonAlpha
        nameEditButton.addTarget(self, action: #selector(MainGroupInfoView.tapEditName(_:)), for: .touchUpInside)
        self.addSubview(nameEditButton)
        
        // configure image view
        groupPhotoImageView.frame = CGRect(x: self.bounds.midX - Constants.groupPhotoRadius/2, y: self.bounds.minY + Constants.groupPhotoOriginY, width: Constants.groupPhotoRadius, height: Constants.groupPhotoRadius)
        groupPhotoImageView.layer.cornerRadius = Constants.groupImageCornerRadius
        groupPhotoImageView.layer.masksToBounds = true
        groupPhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(groupPhotoImageView)
        
        // MemberTextField
        memberTextField.defaultPlaceholderText = Constants.memberTextFieldPlaceholder
        memberTextField.frame = CGRect(x: self.bounds.midX - Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberTextFieldOriginY, width: Constants.memberTextFieldWidth, height: Constants.memberTextFieldHeight)
        memberTextField.isUserInteractionEnabled = false
        memberTextField.textAlignment = .center
        memberTextField.delegate = self
        self.addSubview(memberTextField)
        
        // MemberEditButton
        memberEditButton.frame = CGRect(x: self.bounds.midX + Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        memberEditButton.setImage(UIImage(named: "edit"), for: .normal)
        memberEditButton.alpha = Constants.editButtonAlpha
        nameEditButton.addTarget(self, action: #selector(MainGroupInfoView.tapEditMember(_:)), for: .touchUpInside)
        self.addSubview(memberEditButton)
        
        // Member Table
        if let mTCV = memberTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginY, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeight)
            mTCV.backgroundColor = UIColor.orange
            
            self.addSubview(mTCV)
        }
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapEditName(_ gestureRecognizer: UITapGestureRecognizer) {
        nameTextField.isUserInteractionEnabled = true
        nameTextField.becomeFirstResponder()
    }
    
    func tapEditMember(_ gestureRecognizer: UITapGestureRecognizer) {
        nameTextField.isUserInteractionEnabled = true
        memberTextField.becomeFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false
    }
    
}

private struct Constants {
    static let groupPhotoOriginY: CGFloat = 75
    static let groupPhotoRadius: CGFloat = 80
    static let groupImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldPlaceholder = "Group Name"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 40
    
    static let nameEditButtonOriginY: CGFloat = 186
    static let editButtonAlpha: CGFloat = 0.2
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let memberTextFieldPlaceholder = "Members"
    static let memberTextFieldOriginY: CGFloat = 250
    static let memberTextFieldWidth: CGFloat = 150
    static let memberTextFieldHeight: CGFloat = 40
    
    static let memberEditButtonOriginY: CGFloat = 261
    
    static let memberTableMarginConstant: CGFloat = 20
    static let memberTableOriginY: CGFloat = 300
    static let memberTableHeight: CGFloat = 300
}

