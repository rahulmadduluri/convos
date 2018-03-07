//
//  SearchBottomBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchBottomBarView: UIView, SearchUIComponent {
    
    var searchVC: SearchComponentDelegate?
    var searchTextField: SmartTextField?
    var searchButton = UIButton()
    var contactsButton = UIButton()
    var profileButton = UIButton()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        searchButton.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.size.width / 3, height: self.bounds.height)
        searchButton.backgroundColor = UIColor.white.withAlphaComponent(Constants.buttonBackgroundAlpha)
        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.imageEdgeInsets = UIEdgeInsets(top: Constants.buttonImageEdgeInset, left: Constants.buttonImageEdgeInset, bottom: Constants.buttonImageEdgeInset, right: Constants.buttonImageEdgeInset)
        searchButton.addTarget(self, action: #selector(SearchBottomBarView.tapSearch(_:)), for: .touchUpInside)
        self.addSubview(searchButton)
        
        contactsButton.frame = CGRect(x: self.bounds.minX + self.bounds.size.width/3, y: self.bounds.minY, width: self.bounds.size.width / 3, height: self.bounds.height)
        contactsButton.backgroundColor = UIColor.white.withAlphaComponent(Constants.buttonBackgroundAlpha)
        contactsButton.imageView?.contentMode = .scaleAspectFit
        contactsButton.setImage(UIImage(named: "contacts"), for: .normal)
        contactsButton.imageEdgeInsets = UIEdgeInsets(top: Constants.buttonImageEdgeInset, left: Constants.buttonImageEdgeInset, bottom: Constants.buttonImageEdgeInset, right: Constants.buttonImageEdgeInset)
        contactsButton.addTarget(self, action: #selector(SearchBottomBarView.tapContacts(_:)), for: .touchUpInside)
        self.addSubview(contactsButton)

        profileButton.frame = CGRect(x: self.bounds.minX + self.bounds.size.width*2/3, y: self.bounds.minY, width: self.bounds.size.width / 3, height: self.bounds.height)
        profileButton.backgroundColor = UIColor.white.withAlphaComponent(Constants.buttonBackgroundAlpha)
        profileButton.imageView?.contentMode = .scaleAspectFit
        profileButton.setImage(UIImage(named: "profile"), for: .normal)
        profileButton.imageEdgeInsets = UIEdgeInsets(top: Constants.buttonImageEdgeInset, left: Constants.buttonImageEdgeInset, bottom: Constants.buttonImageEdgeInset, right: Constants.buttonImageEdgeInset)
        self.addSubview(profileButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapSearch(_ gestureRecognizer: UITapGestureRecognizer) {
        searchTextField?.becomeFirstResponder()
    }
    
    func tapContacts(_ gestureRecognizer: UITapGestureRecognizer) {
        searchVC?.contactsSelected()
    }
}

private struct Constants {
    static let buttonImageEdgeInset: CGFloat = 15
    static let buttonBackgroundAlpha: CGFloat = 0.9
}
