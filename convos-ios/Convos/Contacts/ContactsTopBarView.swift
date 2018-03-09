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
    var addNewContactButton = UIButton()
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
        
        // AddNewContactsButton
        addNewContactButton.frame = CGRect(x: self.bounds.maxX - Constants.addContactButtonTrailingMargin - Constants.addContactButtonRadius, y: self.bounds.minY + Constants.addContactButtonOriginY, width: Constants.addContactButtonRadius, height: Constants.addContactButtonRadius)
        addNewContactButton.setImage(UIImage(named: "new_group"), for: .normal)
        addNewContactButton.setImage(UIImage(named: "cancel"), for: .selected)
        addNewContactButton.addTarget(self, action: #selector(ContactsTopBarView.tapAddContact(_:)), for: .touchUpInside)
        self.addSubview(addNewContactButton)
    }
        
    // MARK: Gesture Recognizer functions
    
    func tapAddContact(_ obj: Any) {
        addNewContactButton.isSelected = !addNewContactButton.isSelected
        contactTextField.text = ""
        contactsVC?.addContactSelected()
    }

}

private struct Constants {
    static let editButtonRadius: CGFloat = 20
    
    static let contactTextFieldPlaceholder: String = "Search Contacts"
    static let contactTextFieldOriginY: CGFloat = 0
    static let contactTextFieldWidth: CGFloat = 200
    static let contactTextFieldHeight: CGFloat = 40
    
    static let addContactButtonOriginY: CGFloat = 5
    static let addContactButtonTrailingMargin: CGFloat = 10
    static let addContactButtonRadius: CGFloat = 30
    
    static let contactEditButtonOriginY: CGFloat = 5
}
