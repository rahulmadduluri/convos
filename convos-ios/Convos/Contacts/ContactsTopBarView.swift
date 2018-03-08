//
//  ContactsTopBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/7/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class ContactsTopBarView: UIView, ContactsUIComponent {
    var contactsVC: ContactsComponentDelegate?
    var contactEditCancelButton = UIButton()
    var contactTextField: SmartTextField = SmartTextField()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // ContactTextField
        contactTextField.defaultPlaceholderText = Constants.contactTextFieldPlaceholder
        contactTextField.frame = CGRect(x: self.bounds.midX - Constants.contactTextFieldWidth/2, y: self.bounds.minY + Constants.contactTextFieldOriginY, width: Constants.contactTextFieldWidth, height: Constants.contactTextFieldHeight)
        contactTextField.textAlignment = .center
        contactTextField.smartTextFieldDelegate = contactsVC
        contactTextField.delegate = contactsVC
        self.addSubview(contactTextField)
        
        // ContactEditCancelButton
        contactEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.contactTextFieldWidth/2, y: self.bounds.minY + Constants.contactEditButtonOriginY, width: Constants.editButtonRadius, height: Constants.editButtonRadius)
        contactEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        contactEditCancelButton.alpha = 0
        contactEditCancelButton.addTarget(self, action: #selector(ContactsTopBarView.tapContactEditCancel(_:)), for: .touchUpInside)
        self.addSubview(contactEditCancelButton)
    }
        
    // MARK: Gesture Recognizer functions
    
    func tapContactEditCancel(_ obj: Any) {
        contactEditCancelButton.alpha = 0
        
        contactTextField.text = ""
        contactsVC?.resetContacts()
        
        contactTextField.resignFirstResponder()
    }

}

private struct Constants {
    static let editButtonRadius: CGFloat = 20
    
    static let contactTextFieldPlaceholder: String = "Search Contacts"
    static let contactTextFieldOriginY: CGFloat = 0
    static let contactTextFieldWidth: CGFloat = 150
    static let contactTextFieldHeight: CGFloat = 40
    
    static let contactEditButtonOriginY: CGFloat = 5
}
