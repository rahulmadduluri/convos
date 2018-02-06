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
    let rightInfoButton = UIButton()
    
    var section = 0
    var searchVC: SearchComponentDelegate?
    
    // MARK: Initalizers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.purple
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.layer.cornerRadius = Constants.imageCornerRadius
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
        
        // Right GroupInfo Button
        contentView.addSubview(rightInfoButton)
        rightInfoButton.translatesAutoresizingMaskIntoConstraints = false
        rightInfoButton.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor, constant: Constants.trailingRightInfoAnchorConstant).isActive = true
        rightInfoButton.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        rightInfoButton.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.rightInfoWidth).isActive = true
        rightInfoButton.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.rightInfoHeight).isActive = true
        rightInfoButton.setImage(UIImage(named: "info_button"), for: .normal)
        rightInfoButton.alpha = Constants.rightInfoAlpha
        rightInfoButton.addTarget(self, action: #selector(SearchTableViewHeader.tapInfo(_:)), for: .touchUpInside)
        
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
    static let leadingImageAnchorConstant: CGFloat = 11
    static let leadingLabelAnchorConstant: CGFloat = 25
    static let trailingRightInfoAnchorConstant: CGFloat = 0
    static let imageWidth: CGFloat = 26
    static let imageHeight: CGFloat = 26
    static let imageCornerRadius: CGFloat = 13
    static let rightInfoWidth: CGFloat = 18
    static let rightInfoHeight: CGFloat = 18
    static let rightInfoAlpha: CGFloat = 0.5
}
