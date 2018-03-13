//
//  MainUserInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainUserInfoView: UIView, UserInfoUIComponent, UITextFieldDelegate {
    
    fileprivate var nameEditCancelButton = UIButton()
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var userInfoVC: UserInfoComponentDelegate? = nil
    var nameTextField = UITextField()
    var userPhotoImageView = UIImageView()
    var mobileNumberTextField = UITextField()
    
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
        
        // nameEditCancelButton
        nameEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.nameTextFieldWidth/2, y: self.bounds.minY + Constants.nameEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        nameEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        nameEditCancelButton.alpha = 0
        nameEditCancelButton.addTarget(self, action: #selector(MainUserInfoView.tapNameEditCancel(_:)), for: .touchUpInside)
        self.addSubview(nameEditCancelButton)
        
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
        mobileNumberTextField.textAlignment = .center
        mobileNumberTextField.delegate = self
        self.addSubview(mobileNumberTextField)
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapNameEditCancel(_ obj: Any) {
        nameEditCancelButton.alpha = 0
        
        nameTextField.text = ""
        
        nameTextField.resignFirstResponder()
    }
    
    func tapUserPhoto(_ obj: Any) {
        userInfoVC?.presentAlertOption(tag: userPhotoImageView.tag)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editAlertHasBeenPressed == true {
            editAlertHasBeenPressed = false
            return true
        } else {
            userInfoVC?.presentAlertOption(tag: textField.tag)
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if textField.tag == Constants.nameTextFieldTag {
            userInfoVC?.userNameEdited(name: text)
            nameEditCancelButton.alpha = 0
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
        } else if tag == Constants.userPhotoTag {
            
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
    static let nameTextFieldHeight: CGFloat = 60
    static let nameTextFieldFontSize: CGFloat = 24
    
    static let nameEditButtonOriginY: CGFloat = 196
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let mobileTextFieldPlaceholder: String = "+(!!!!!)13090203930"
    static let mobileTextFieldOriginY: CGFloat = 175
    static let mobileTextFieldWidth: CGFloat = 200
    static let mobileTextFieldHeight: CGFloat = 60
    static let mobileTextFieldFontSize: CGFloat = 24
   
    static let nameTextFieldTag: Int = 1
    static let userPhotoTag: Int = 2
}
