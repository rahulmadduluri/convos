//
//  SearchCollectionViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/16/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: CustomCollectionViewCell, SearchUIComponent {
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()

    var delegate: SearchTableComponentDelegate?
    var type: SearchViewType?
}
