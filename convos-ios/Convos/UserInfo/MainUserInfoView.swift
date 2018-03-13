//
//  MainUserInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainUserInfoView: UIView, UserInfoUIComponent, UITextFieldDelegate {
    
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var userInfoVC: UserInfoComponentDelegate? = nil
    var nameTextField = UITextField()
    var handleTextField = UITextField()
    var userPhotoImageView = UIImageView()
    var mobileNumberTextField = UITextField()
    var logoutButton = UIButton()
    
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
        mobileNumberTextField.placeholder = Constants.mobileTextFieldPlaceholder
        mobileNumberTextField.textAlignment = .center
        mobileNumberTextField.delegate = self
        self.addSubview(mobileNumberTextField)
        
        // LogoutButton
        logoutButton.frame = CGRect(x: self.bounds.midX - Constants.logoutButtonRadius/2, y: self.bounds.minY + Constants.logoutButtonOriginY, width: Constants.logoutButtonRadius, height: Constants.logoutButtonRadius)
        logoutButton.setImage(UIImage(named: "logout"), for: .normal)
        logoutButton.alpha = (userInfoVC?.isMe ?? false) ? 1 : 0
        logoutButton.tag = Constants.logoutButtonTag
        logoutButton.addTarget(self, action: #selector(MainUserInfoView.tapLogout(_:)), for: .touchUpInside)
        self.addSubview(logoutButton)
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapUserPhoto(_ obj: Any) {
        userInfoVC?.presentAlertOption(tag: userPhotoImageView.tag)
    }
    
    func tapLogout(_ obj: Any) {
        userInfoVC?.presentAlertOption(tag: logoutButton.tag)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == Constants.nameTextFieldTag || textField.tag == Constants.userPhotoTag || textField.tag == Constants.handleTextFieldTag {
            if editAlertHasBeenPressed == true {
                editAlertHasBeenPressed = false
                return true
            } else {
                userInfoVC?.presentAlertOption(tag: textField.tag)
                return false
            }
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if textField.tag == Constants.nameTextFieldTag {
            userInfoVC?.userNameEdited(name: text)
        } else if textField.tag == Constants.handleTextFieldTag {
            userInfoVC?.userHandleEdited(handle: text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func beginEditPressed(tag: Int) {
        editAlertHasBeenPressed = true
        if tag == Constants.nameTextFieldTag {
            nameTextField.becomeFirstResponder()
        } else if tag == Constants.userPhotoTag {
            
        } else if tag == Constants.handleTextFieldTag {
            handleTextField.becomeFirstResponder()
        }
    }
    
}

private struct Constants {
    static let userPhotoOriginY: CGFloat = 75
    static let userPhotoRadius: CGFloat = 80
    static let userImageCornerRadius: CGFloat = 40
    
    static let nameTextFieldPlaceholder: String = "Member Name"
    static let nameTextFieldOriginY: CGFloat = 175
    static let nameTextFieldWidth: CGFloat = 150
    static let nameTextFieldHeight: CGFloat = 40
    static let nameTextFieldFontSize: CGFloat = 24
    
    static let handleTextFieldPlaceholder: String = "@userhandle"
    static let handleTextFieldOriginY: CGFloat = 210
    static let handleTextFieldWidth: CGFloat = 200
    static let handleTextFieldHeight: CGFloat = 40
    static let handleTextFieldFontSize: CGFloat = 16
    
    static let mobileTextFieldPlaceholder: String = "111:)111"
    static let mobileTextFieldOriginY: CGFloat = 260
    static let mobileTextFieldWidth: CGFloat = 200
    static let mobileTextFieldHeight: CGFloat = 40
    static let mobileTextFieldFontSize: CGFloat = 24
    
    static let logoutButtonOriginY: CGFloat = 600
    static let logoutButtonRadius: CGFloat = 40
   
    static let nameTextFieldTag: Int = 1
    static let userPhotoTag: Int = 2
    static let handleTextFieldTag: Int = 3
    static let logoutButtonTag: Int = 4
}
