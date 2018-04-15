//
//  MainNewUserView.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/15/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainNewUserView: UIView, UITextFieldDelegate {
    var newUserVC: NewUserUIComponentDelegate? = nil
    var nameTextField = UITextField()
    var handleTextField = UITextField()
    var userPhotoImageView = UIImageView()
    var mobileNumberTextField = UITextField()
    var createUserButton = UIButton()
    
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
        nameTextField.alpha = 1
        self.addSubview(nameTextField)
        
        // HandleTextField
        handleTextField.placeholder = Constants.handleTextFieldPlaceholder
        handleTextField.frame = CGRect(x: self.bounds.midX - Constants.handleTextFieldWidth/2, y: self.bounds.minY + Constants.handleTextFieldOriginY, width: Constants.handleTextFieldWidth, height: Constants.handleTextFieldHeight)
        handleTextField.font = handleTextField.font?.withSize(Constants.handleTextFieldFontSize)
        handleTextField.textAlignment = .center
        handleTextField.tag = Constants.handleTextFieldTag
        handleTextField.alpha = 1
        handleTextField.delegate = self
        self.addSubview(handleTextField)
        
        // configure image view
        userPhotoImageView.frame = CGRect(x: self.bounds.midX - Constants.userPhotoRadius/2, y: self.bounds.minY + Constants.userPhotoOriginY, width: Constants.userPhotoRadius, height: Constants.userPhotoRadius)
        userPhotoImageView.layer.cornerRadius = Constants.userImageCornerRadius
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainUserInfoView.tapUserPhoto(_:)))
        singleTap.numberOfTapsRequired = 1
        userPhotoImageView.addGestureRecognizer(singleTap)
        userPhotoImageView.tag = Constants.userPhotoTag
        self.addSubview(userPhotoImageView)
        
        // MobileNumberTextField
        mobileNumberTextField.frame = CGRect(x: self.bounds.midX - Constants.mobileTextFieldWidth/2, y: self.bounds.minY + Constants.mobileTextFieldOriginY, width: Constants.mobileTextFieldWidth, height: Constants.mobileTextFieldHeight)
        mobileNumberTextField.font = mobileNumberTextField.font?.withSize(Constants.mobileTextFieldFontSize)
        mobileNumberTextField.alpha = 1.0
        mobileNumberTextField.tag = Constants.mobileNumberTag
        mobileNumberTextField.textAlignment = .center
        mobileNumberTextField.delegate = self
        self.addSubview(mobileNumberTextField)
        
        // CreateUserButton
        createUserButton.frame = CGRect(x: self.bounds.midX - Constants.createUserButtonRadius/2, y: self.bounds.minY + Constants.createUserButtonOriginY, width: Constants.createUserButtonRadius, height: Constants.createUserButtonRadius)
        createUserButton.setImage(UIImage(named: "rocket_launch"), for: .normal)
        createUserButton.addTarget(self, action: #selector(MainNewUserView.tapCreateUser(_:)), for: .touchUpInside)
        self.addSubview(createUserButton)
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapUserPhoto(_ obj: Any) {
        // bring up image picker
    }
    
    func tapCreateUser(_ obj: Any) {
        newUserVC?.createUserTapped()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // can't edit mobile #
        return textField.tag != Constants.mobileNumberTag
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
}

private struct Constants {
    static let userPhotoOriginY: CGFloat = 75
    static let userPhotoRadius: CGFloat = 80
    static let userImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldPlaceholder: String = "Name"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 40
    static let nameTextFieldFontSize: CGFloat = 24
    
    static let handleTextFieldPlaceholder: String = "@userhandle"
    static let handleTextFieldOriginY: CGFloat = 210
    static let handleTextFieldWidth: CGFloat = 200
    static let handleTextFieldHeight: CGFloat = 40
    static let handleTextFieldFontSize: CGFloat = 16
    
    static let mobileTextFieldOriginY: CGFloat = 260
    static let mobileTextFieldWidth: CGFloat = 200
    static let mobileTextFieldHeight: CGFloat = 40
    static let mobileTextFieldFontSize: CGFloat = 24
    
    static let createUserButtonOriginY: CGFloat = 600
    static let createUserButtonRadius: CGFloat = 40
    
    static let nameTextFieldTag: Int = 1
    static let userPhotoTag: Int = 2
    static let handleTextFieldTag: Int = 3
    static let mobileNumberTag: Int = 4
    static let createUserButtonTag: Int = 5
}
