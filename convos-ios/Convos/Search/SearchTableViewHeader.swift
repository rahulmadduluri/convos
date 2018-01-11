//
//  SearchTableViewHeader.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewHeader: UITableViewHeaderFooterView {
    
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    
    var section = 0
    
    var searchViewData: SearchViewData? {
        get {
            return self.searchViewData
        }
        set {
            self.searchViewData = newValue
            customTextLabel.text = searchViewData?.text
            photoImageView.image = searchViewData?.photo
        }
    }
    
    // MARK: Initalizers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //let marginGuide = contentView.layoutMarginsGuide
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
