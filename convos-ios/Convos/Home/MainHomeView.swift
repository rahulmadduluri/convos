//
//  MainHomeView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/28/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MainHomeView: UIView {
    
    var searchContainerView: UIView? = nil
    
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
        
        // Search Container
        if let sCV = searchContainerView {
            sCV.bounds = CGRect(x: 100, y: 200, width: self.bounds.width, height: 500)
            
            self.addSubview(sCV)
        }
    }

}
