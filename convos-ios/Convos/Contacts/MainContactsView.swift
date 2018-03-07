//
//  MainContactsView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/6/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainContactsView: UIView, ContactsUIComponent, UITextFieldDelegate {
    fileprivate var contactsEditCancelButton = UIButton()
    
    var contactsVC: ContactsComponentDelegate? = nil
    var contactTextField: SmartTextField = SmartTextField()
    var contactEditCancelButton = UIButton()
    var contactsTableContainerView: UIView? = nil
    
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
        
        // ContactTextField
        contactTextField.defaultPlaceholderText = Constants.contactTextFieldPlaceholder
        contactTextField.frame = CGRect(x: self.bounds.midX - Constants.contactTextFieldWidth/2, y: self.bounds.minY + Constants.contactTextFieldOriginY, width: Constants.contactTextFieldWidth, height: Constants.contactTextFieldHeight)
        contactTextField.textAlignment = .center
        contactTextField.tag = Constants.contactTextFieldTag
        contactTextField.delegate = self
        self.addSubview(contactTextField)
        
        // ContactEditCancelButton
        contactEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.contactTextFieldWidth/2, y: self.bounds.minY + Constants.contactEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        contactEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        contactEditCancelButton.alpha = 0
        contactEditCancelButton.addTarget(self, action: #selector(MainGroupInfoView.tapMemberEditCancel(_:)), for: .touchUpInside)
        self.addSubview(contactEditCancelButton)
        
        // Contacts Table
        if let cTCV = contactsTableContainerView {
            contactsTableContainerView?.frame = CGRect(x: self.bounds.minX + Constants.contactsTableMarginConstant, y: self.bounds.minY + Constants.contactsTableOriginY, width: self.bounds.width - Constants.contactsTableMarginConstant*2, height: Constants.contactsTableHeight)
            
            self.addSubview(cTCV)
        }
        
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapContactEditCancel(_ obj: Any) {
        contactEditCancelButton.alpha = 0
        
        contactTextField.text = ""
        contactsVC?.resetContacts()
        
        contactTextField.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == Constants.contactTextFieldTag {
            contactsVC?.contactSearchUpdated()
            contactTextField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
}

private struct Constants {
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let contactTextFieldPlaceholder: String = "Search Contacts"
    static let contactTextFieldOriginY: CGFloat = 250
    static let contactTextFieldWidth: CGFloat = 200
    static let contactTextFieldHeight: CGFloat = 40
    
    static let contactEditButtonOriginY: CGFloat = 261
    
    static let contactsTableMarginConstant: CGFloat = 25
    static let contactsTableOriginY: CGFloat = 300
    static let contactsTableHeight: CGFloat = 275
    
    static let contactTextFieldTag: Int = 1
}
