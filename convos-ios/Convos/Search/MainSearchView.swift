//
//  MainSearchView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/20/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MainSearchView: UIView {
    
    var searchTextField: SearchTextField = SearchTextField()
    var searchTableContainerView: UIView? = nil
    
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
        
        // SearchTextField
        searchTextField.frame = Constants.searchTextFieldFrame
        self.addSubview(searchTextField)
        
        // Search Table
        if let sCTV = searchTableContainerView {
            sCTV.bounds = CGRect(x: self.bounds.minX, y: Constants.searchTextFieldFrame.maxY, width: self.bounds.width, height: Constants.searchResultsTableHeight)
            
            self.addSubview(sCTV)
        }
    }
}

private struct Constants {
    static let searchTextFieldFrame = CGRect(x: 100, y: 200, width: 200, height: 100)
    static let searchResultsTableHeight: CGFloat = 300
}



