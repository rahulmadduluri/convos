//
//  MainConversationView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/20/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MainConversationView: UIView {
    
    let titleLabel = UILabel()
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.blue
        self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    // MARK: Public
    
    func setTitle(newTitle: String) {
        titleLabel.text = newTitle
    }
    
    func addMessage(data: MessageViewData) {
        
    }
}
