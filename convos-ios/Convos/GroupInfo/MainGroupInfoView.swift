//
//  MainGroupInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainGroupInfoView: UIView, GroupInfoUIComponent {
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var groupPhotoImageView = UIImageView()
    var nameEditButton = UIButton()
    var nameTextField = UITextField()
    var memberTextField: SmartTextField = SmartTextField()
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
        nameTextField.placeholder = "Group Name"
        nameTextField.frame = CGRect(x: self.bounds.midX - Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameTextFieldOriginY, width: Constants.nameTextFieldWidth, height: Constants.nameTextFieldHeight)
        nameTextField.textAlignment = .center
        nameTextField.backgroundColor = UIColor.purple
        self.addSubview(nameTextField)
        
        // configure image view
        groupPhotoImageView.frame = CGRect(x: self.bounds.midX - Constants.groupPhotoRadius/2, y: self.bounds.minY + Constants.groupPhotoOriginY, width: Constants.groupPhotoRadius, height: Constants.groupPhotoRadius)
        groupPhotoImageView.layer.cornerRadius = Constants.groupImageCornerRadius
        groupPhotoImageView.layer.masksToBounds = true
        groupPhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(groupPhotoImageView)
        
        // MemberTextField
        memberTextField.defaultPlaceholderText = "Members"
        memberTextField.frame = CGRect(x: self.bounds.midX - Constants.memberTextFieldWidth/2, y: self.bounds.minY + Constants.memberTextFieldOriginY, width: Constants.memberTextFieldWidth, height: Constants.memberTextFieldHeight)
        memberTextField.textAlignment = .center
        memberTextField.backgroundColor = UIColor.purple
        self.addSubview(memberTextField)
        
        // Member Table
        if let mTCV = memberTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginY, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeight)
            mTCV.backgroundColor = UIColor.orange
            
            self.addSubview(mTCV)
        }
    }
}

private struct Constants {
    static let groupPhotoOriginY: CGFloat = 75
    static let groupPhotoRadius: CGFloat = 80
    static let groupImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 40
    
    static let memberTextFieldOriginY: CGFloat = 250
    static let memberTextFieldWidth: CGFloat = 150
    static let memberTextFieldHeight: CGFloat = 40
    
    static let memberTableMarginConstant: CGFloat = 20
    static let memberTableOriginY: CGFloat = 300
    static let memberTableHeight: CGFloat = 300
}

