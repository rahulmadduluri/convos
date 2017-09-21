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
    var messagesTableContainerView: UIView? = nil
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.white
        self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // Title
        titleLabel.text = "TEST_TITLE"
        titleLabel.center = CGPoint(x: bounds.width/2, y: 50)
        titleLabel.bounds.size = titleLabel.intrinsicContentSize
        self.addSubview(titleLabel)
        
        // Messages Table
        if let mTCV = messagesTableContainerView {
            mTCV.backgroundColor = UIColor.blue
            mTCV.bounds = CGRect(x: self.bounds.minX, y: self.bounds.minY + 100, width: self.bounds.width, height: self.bounds.maxY - 150)
            
            self.addSubview(mTCV)
        }
    }
    
    // MARK: Public
    
    // MUST be called after layout subviews
    func addConversationTableSubview(tableContainerView: UIView) {

    }
    
    func setTitle(newTitle: String) {
        titleLabel.text = newTitle
    }
}
