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
    var searchVC: SearchComponentDelegate?
    
    // MARK: Initalizers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        contentView.backgroundColor = UIColor.white
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.layer.cornerRadius = Constants.imageCornerRadius
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: Constants.leadingImageAnchorConstant).isActive = true
        photoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageRadius).isActive = true
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageRadius).isActive = true
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchTableViewHeader.tapGroupInfo(_:))))
        
        // Title label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.leadingLabelAnchorConstant).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = UIFont.systemFont(ofSize: Constants.textFontSize)
        customTextLabel.isUserInteractionEnabled = true
        customTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchTableViewHeader.tapGroupInfo(_:))))
        
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
    
    func tapGroupInfo(_ gestureRecognizer: UITapGestureRecognizer) {
        if let defaultConvo = searchVC?.getSearchViewData().keys[section] {
            if let uuid = defaultConvo.uuid,
                defaultConvo.type == SearchViewType.defaultConversation.rawValue {
                searchVC?.groupSelected(conversationUUID: uuid)
            }
        }
    }
    
}

private struct Constants {
    static let textFontSize: CGFloat = 16
    static let leadingLabelAnchorConstant: CGFloat = 25
    
    static let leadingImageAnchorConstant: CGFloat = -3
    static let imageRadius: CGFloat = 26
    static let imageCornerRadius: CGFloat = 13
}
