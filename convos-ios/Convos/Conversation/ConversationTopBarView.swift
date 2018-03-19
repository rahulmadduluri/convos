//
//  ConversationTopBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class ConversationTopBarView: UIView, ConversationUIComponent {

    var conversationVC: ConversationComponentDelegate?    
    let titleLabel = UILabel()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
        addGestureRecognizer(panGestureRecognizer)

        // Setup Title
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: Public
    
    func setTitle(newTitle: String) {
        titleLabel.text = newTitle
        titleLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        titleLabel.bounds.size = titleLabel.intrinsicContentSize
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self)
            if (translation.y > 25) {
                conversationVC?.showSwitcher()
            }
        }
    }
}
