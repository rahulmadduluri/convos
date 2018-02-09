//
//  MainGroupInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainGroupInfoView: UIView {
    
    var memberTextField: SmartTextField = SmartTextField()
    var memberTableContainerView: UIView? = nil
    
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
        
        // MemberTextField
        memberTextField.frame = CGRect(x: self.bounds.minX + Constants.memberTextFieldOriginXOffset, y: self.bounds.minY, width: Constants.memberTextFieldWidth, height: Constants.memberTextFieldHeight)
        self.addSubview(memberTextField)
        
        // Member Table
        if let mTCV = memberTableContainerView {
            mTCV.frame = CGRect(x: self.bounds.minX + Constants.memberTableMarginConstant, y: self.bounds.minY + Constants.memberTableOriginY, width: self.bounds.width - Constants.memberTableMarginConstant*2, height: Constants.memberTableHeight)
            
            self.addSubview(mTCV)
        }
    }
}

private struct Constants {
    static let memberTableMarginConstant: CGFloat = 20
    static let memberTableOriginY: CGFloat = 200
    static let memberTableHeight: CGFloat = 100
    static let memberTextFieldOriginXOffset: CGFloat = 100
    static let memberTextFieldWidth: CGFloat = 200
    static let memberTextFieldHeight: CGFloat = 75
}

