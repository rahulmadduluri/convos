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
    var switchConversationCollection = SwitchConversationCollectionView()
    var bottomBarView: ConversationBottomBarView = ConversationBottomBarView()
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
        
        topBarView.frame = CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY + Constants.topBarBuffer,
            width: self.bounds.width,
            height: Constants.topBarHeight)
        self.addSubview(topBarView)
        
        // Bottom Message Entry Bar
        bottomBarView.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.maxY-Constants.bottomBarHeight, width: self.bounds.width, height: Constants.bottomBarHeight)
        self.addSubview(bottomBarView)
        
        // Messages Table
        if let mTCV = messagesTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY + Constants.topBarBuffer + Constants.topBarHeight, width: self.bounds.width, height: self.bounds.maxY - Constants.topBarBuffer - Constants.bottomBarHeight - Constants.topBarHeight)
            
            self.addSubview(mTCV)
        }
    }    
}

private struct Constants {
    static let topBarBuffer: CGFloat = 20
    static let topBarHeight: CGFloat = 40
    static let bottomBarHeight: CGFloat = 50
}
