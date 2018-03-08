//
//  MainContactsView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/6/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainContactsView: UIView, ContactsUIComponent {
    var contactsVC: ContactsComponentDelegate? = nil
    var topBarView: ContactsTopBarView = ContactsTopBarView()
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

        topBarView.frame = CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY + Constants.topBarOriginY,
            width: self.bounds.width,
            height: Constants.topBarHeight)
        topBarView.contactsVC = contactsVC
        self.addSubview(topBarView)

        // Contacts Table
        if let cTCV = contactsTableContainerView {
            contactsTableContainerView?.frame = CGRect(x: self.bounds.minX + Constants.contactsTableMarginConstant, y: self.bounds.minY + Constants.contactsTableOriginY, width: self.bounds.width - Constants.contactsTableMarginConstant*2, height: self.bounds.height - Constants.topBarOriginY - Constants.topBarHeight)
            
            self.addSubview(cTCV)
        }
    }

}

private struct Constants {
    static let topBarOriginY: CGFloat = 20
    static let topBarHeight: CGFloat = 40
        
    static let contactsTableMarginConstant: CGFloat = 25
    static let contactsTableOriginY: CGFloat = 60
}
