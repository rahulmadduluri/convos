//
//  SearchTableViewHeader.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewHeader: UITableViewHeaderFooterView, SearchUIComponent {
    
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    
    var section = 0
    var searchVC: SearchTableComponentDelegate?
    
    // MARK: Initalizers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.red
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.layer.cornerRadius = 15.0
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: Constants.leadingImageAnchorConstant).isActive = true
        photoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageWidth).isActive = true
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageHeight).isActive = true
        
        // Title label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.leadingLabelAnchorConstant).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = UIFont.systemFont(ofSize: Constants.textFontSize)
        
        
        // UIGestureRecognizer
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Gesture Recognizer
    
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        if let defaultConvo = searchVC?.getSearchViewData().keys[section] {
            if let uuid = defaultConvo.uuid,
                defaultConvo.type == SearchViewType.defaultConversation.rawValue {
                searchVC?.convoSelected(uuid: uuid)
            }
        }
    }
    
    func tapInfo(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let header = gestureRecognizer.view as? SearchTableViewHeader,
            let svd = header.searchVC?.getSearchViewData().keys[header.section],
            let uuid = svd.uuid else {
                return
        }
        
        searchVC?.convoSelected(uuid: uuid)
    }

}

private struct Constants {
    static let textFontSize: CGFloat = 16
    static let leadingImageAnchorConstant: CGFloat = 20
    static let leadingLabelAnchorConstant: CGFloat = 60
    static let imageWidth: CGFloat = 24
    static let imageHeight: CGFloat = 24
}
