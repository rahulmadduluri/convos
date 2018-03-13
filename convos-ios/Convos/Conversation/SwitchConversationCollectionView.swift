//
//  SwitchConversationCollectionView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SwitchConversationCollectionView: UIView {
    var conversationVC: SearchComponentDelegate? = nil
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
