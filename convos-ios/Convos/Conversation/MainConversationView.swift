//
//  MainConversationView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/20/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MainConversationView: UIView {
    
    var topBarView: ConversationTopBarView = ConversationTopBarView()
    var messagesTableContainerView: UIView? = nil
    
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
        
        // Conversation Top Bar View
        topBarView.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: 50)
        self.addSubview(topBarView)
        
        // Messages Table
        if let mTCV = messagesTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY + 100, width: self.bounds.width, height: self.bounds.maxY - 150)
            
            self.addSubview(mTCV)
        }
    }    
}
