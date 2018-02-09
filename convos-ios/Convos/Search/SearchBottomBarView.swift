//
//  SearchBottomBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchBottomBarView: UIView {
    
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
        searchButton.backgroundColor = UIColor.blue
        self.addSubview(searchButton)
        
        contactsButton.frame = CGRect(x: self.bounds.minX + self.bounds.size.width/3, y: self.bounds.minY, width: self.bounds.size.width / 3, height: self.bounds.height)
        contactsButton.backgroundColor = UIColor.brown
        self.addSubview(contactsButton)

        
        profileButton.frame = CGRect(x: self.bounds.minX + self.bounds.size.width*2/3, y: self.bounds.minY, width: self.bounds.size.width / 3, height: self.bounds.height)
        profileButton.backgroundColor = UIColor.cyan
        self.addSubview(profileButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
