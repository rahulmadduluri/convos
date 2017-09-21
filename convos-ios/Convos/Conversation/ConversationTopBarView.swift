//
//  ConversationTopBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class ConversationTopBarView: UIView {
    let titleLabel = UILabel()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white

        // Setup Title
        setTitle(newTitle: "P-Diddy")
        self.addSubview(titleLabel)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: Public
    
    func setTitle(newTitle: String) {
        titleLabel.text = newTitle
        titleLabel.center = CGPoint(x: bounds.width/2, y: 50)
        titleLabel.bounds.size = titleLabel.intrinsicContentSize
    }
}
