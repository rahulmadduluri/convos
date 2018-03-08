//
//  MainSearchView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/20/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MainSearchView: UIView, SearchUIComponent {
    
    var searchVC: SearchComponentDelegate?
    var searchTextField: SmartTextField = SmartTextField()
    var searchTableContainerView: UIView? = nil
    var newGroupButton: UIButton = UIButton()
    var bottomBarView: SearchBottomBarView = SearchBottomBarView()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.searchTextField.defaultPlaceholderText = "Enter the Convos"
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // SearchTextField
        searchTextField.frame = CGRect(
            x: self.bounds.midX - Constants.searchTextFieldWidth/2,
            y: self.bounds.minY + Constants.searchTextFieldOriginYOffset,
            width: Constants.searchTextFieldWidth,
            height: Constants.searchTextFieldHeight)
        searchTextField.textAlignment = .center
        self.addSubview(searchTextField)
        
        // Search Table
        if let sCTV = searchTableContainerView {
            sCTV.frame = CGRect(
                x: self.bounds.minX,
                y: self.bounds.minY + Constants.searchTextFieldHeight + Constants.searchTextFieldOriginYOffset + Constants.searchTextTableViewBuffer,
                width: self.bounds.width,
                height: self.bounds.maxY-(self.bounds.minY + Constants.searchTextFieldHeight))
            
            self.addSubview(sCTV)
        }
        
        // SearchTextField
        bottomBarView.frame = CGRect(
            x: self.bounds.origin.x,
            y: self.bounds.maxY-Constants.bottomBarHeight,
            width: self.bounds.width,
            height: Constants.bottomBarHeight)
        bottomBarView.searchTextField = searchTextField
        self.addSubview(bottomBarView)
        
        // New Group Button
        newGroupButton.frame = CGRect(
            x: self.bounds.maxX - Constants.newGroupButtonSize - Constants.newGroupButtonTrailingBuffer,
            y: self.bounds.minY + Constants.newGroupButtonTopBuffer,
            width: Constants.newGroupButtonSize,
            height: Constants.newGroupButtonSize)
        newGroupButton.addTarget(self, action: #selector(MainSearchView.tapNewGroup(_:)), for: .touchUpInside)
        newGroupButton.imageView?.contentMode = .scaleAspectFit
        newGroupButton.setImage(UIImage(named: "new_group"), for: .normal)
        self.addSubview(newGroupButton)
    }
    
    func tapNewGroup(_ gestureRecognizer: UITapGestureRecognizer) {
        searchVC?.createGroup()
    }
}

private struct Constants {
    static let searchTextFieldOriginYOffset: CGFloat = 20
    static let searchTextFieldWidth: CGFloat = 200
    static let searchTextFieldHeight: CGFloat = 40
    
    static let searchTextTableViewBuffer: CGFloat = 0
    
    static let newGroupButtonTopBuffer: CGFloat = 25
    static let newGroupButtonTrailingBuffer: CGFloat = 10
    static let newGroupButtonSize: CGFloat = 30
    
    static let bottomBarHeight: CGFloat = 50
}
