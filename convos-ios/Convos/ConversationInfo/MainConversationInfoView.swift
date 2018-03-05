//
//  MainConversationInfoView.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/25/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainConversationInfoView: UIView, ConversationInfoUIComponent, UITextFieldDelegate, TagListViewDelegate {
    
    fileprivate var tagListView = TagListView()
    fileprivate var topicEditCancelButton = UIButton()
    // HACK :( tells text field that the edit alert has been pressed (look at ShouldBeginEditing)
    fileprivate var editAlertHasBeenPressed = false
    
    var conversationInfoVC: ConversationInfoComponentDelegate? = nil
    var topicTextField = UITextField()
    var tagTextField: SmartTextField = SmartTextField()
    var conversationPhotoImageView = UIImageView()
    var createNewConversationButton = UIButton()
    
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
        
        // TopicTextField
        topicTextField.placeholder = Constants.topicTextFieldPlaceholder
        topicTextField.frame = CGRect(x: self.bounds.midX - Constants.topicTextFieldWidth/2, y: self.bounds.minY + Constants.topicTextFieldOriginY, width: Constants.topicTextFieldWidth, height: Constants.topicTextFieldHeight)
        topicTextField.font = topicTextField.font?.withSize(Constants.topicTextFieldFontSize)
        topicTextField.textAlignment = .center
        topicTextField.tag = Constants.topicTextFieldTag
        topicTextField.delegate = self
        topicTextField.alpha = 1
        self.addSubview(topicTextField)
        
        // TopicEditCancelButton
        topicEditCancelButton.frame = CGRect(x: self.bounds.midX + Constants.topicTextFieldWidth/2, y: self.bounds.minY + Constants.topicEditButtonOriginY, width: Constants.editButtonWidth, height: Constants.editButtonHeight)
        topicEditCancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        topicEditCancelButton.alpha = 0
        topicEditCancelButton.addTarget(self, action: #selector(MainConversationInfoView.tapTopicEditCancel(_:)), for: .touchUpInside)
        self.addSubview(topicEditCancelButton)
        
        // configure image view
        conversationPhotoImageView.frame = CGRect(x: self.bounds.midX - Constants.conversationPhotoRadius/2, y: self.bounds.minY + Constants.conversationPhotoOriginY, width: Constants.conversationPhotoRadius, height: Constants.conversationPhotoRadius)
        conversationPhotoImageView.layer.cornerRadius = Constants.conversationImageCornerRadius
        conversationPhotoImageView.layer.masksToBounds = true
        conversationPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainConversationInfoView.tapConversationPhoto(_:)))
        singleTap.numberOfTapsRequired = 1
        conversationPhotoImageView.addGestureRecognizer(singleTap)
        conversationPhotoImageView.tag = Constants.conversationPhotoTag
        self.addSubview(conversationPhotoImageView)
        
        // TagTextField
        tagTextField.defaultPlaceholderText = Constants.tagTextFieldPlaceholder
        tagTextField.frame = CGRect(x: self.bounds.midX - Constants.tagTextFieldWidth/2, y: self.bounds.minY + Constants.tagTextFieldOriginY, width: Constants.tagTextFieldWidth, height: Constants.tagTextFieldHeight)
        tagTextField.textAlignment = .center
        tagTextField.tag = Constants.tagTextFieldTag
        tagTextField.delegate = self
        tagTextField.alpha = 1
        self.addSubview(tagTextField)
        
        // CreateNewConversationButton
        createNewConversationButton.frame = CGRect(x: self.bounds.midX - Constants.createConversationButtonRadius/2, y: self.bounds.minY + Constants.createConversationButtonOriginY, width: Constants.createConversationButtonRadius, height: Constants.createConversationButtonRadius)
        createNewConversationButton.setImage(UIImage(named: "rocket_launch"), for: .normal)
        createNewConversationButton.alpha = 0
        createNewConversationButton.addTarget(self, action: #selector(MainConversationInfoView.tapCreateNewConversation(_:)), for: .touchUpInside)
        self.addSubview(createNewConversationButton)
        
        // Tag List View
        tagListView.frame = CGRect(x: Constants.tagListMargin, y: Constants.tagListViewOriginY, width: self.bounds.maxX-Constants.tagListMargin*2, height: Constants.tagListViewHeight)
        tagListView.tagBackgroundColor = UIColor.darkGray
        tagListView.textFont = UIFont.systemFont(ofSize: 16)
        tagListView.delegate = self
        self.addSubview(tagListView)
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapTopicEditCancel(_ obj: Any) {
        topicEditCancelButton.alpha = 0
        
        if (conversationInfoVC?.isNewConversation ?? false) == true {
            topicTextField.text = ""
        } else {
            topicTextField.text = conversationInfoVC?.getConversation()?.topic
        }
        
        topicTextField.resignFirstResponder()
    }
    
    func tapConversationPhoto(_ obj: Any) {
        conversationInfoVC?.presentAlertOption(tag: conversationPhotoImageView.tag)
    }
    
    func tapCreateNewConversation(_ obj: Any) {
        conversationInfoVC?.conversationCreated(
            topic: topicTextField.text,
            photo: conversationPhotoImageView.image,
            tagNames: tagListView.tagNames()
        )
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editAlertHasBeenPressed == true {
            editAlertHasBeenPressed = false
            return true
        } else {
            conversationInfoVC?.presentAlertOption(tag: textField.tag)
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if textField.tag == Constants.topicTextFieldTag {
            conversationInfoVC?.conversationTopicEdited(topic: text)
            topicEditCancelButton.alpha = 0
        } else if textField.tag == Constants.tagTextFieldTag {
            tagTextField.text = ""
            addTag(name: text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func beginEditPressed(tag: Int) {
        editAlertHasBeenPressed = true
        if tag == Constants.topicTextFieldTag {
            topicEditCancelButton.alpha = 1
            topicTextField.becomeFirstResponder()
        } else if tag == Constants.tagTextFieldTag {
            tagTextField.becomeFirstResponder()
        } else if tag == Constants.conversationPhotoTag {
            
        }
    }
    
    // MARK: Private
    
    fileprivate func addTag(name: String) {
        tagListView.addTag(name).onTap = { [weak self] tagView in
            self?.tagListView.removeTagView(tagView)
        }
    }
    
}

private struct Constants {
    static let conversationPhotoOriginY: CGFloat = 75
    static let conversationPhotoRadius: CGFloat = 80
    static let conversationImageCornerRadius: CGFloat = 40
    
    static let topicTextFieldPlaceholder: String = "Name Topic"
    static let topicTextFieldOriginY: CGFloat = 175
    static let topicTextFieldWidth: CGFloat = 150
    static let topicTextFieldHeight: CGFloat = 60
    static let topicTextFieldFontSize: CGFloat = 24
    
    static let topicEditButtonOriginY: CGFloat = 196
    static let editButtonWidth: CGFloat = 20
    static let editButtonHeight: CGFloat = 20
    
    static let tagTextFieldPlaceholder: String = "New Tag"
    static let tagTextFieldOriginY: CGFloat = 250
    static let tagTextFieldWidth: CGFloat = 150
    static let tagTextFieldHeight: CGFloat = 40
    
    static let tagEditButtonOriginY: CGFloat = 261
    
    static let createConversationButtonOriginY: CGFloat = 600
    static let createConversationButtonRadius: CGFloat = 40
    
    static let tagListViewOriginY: CGFloat = 300
    static let tagListViewHeight: CGFloat = 275
    static let tagListMargin: CGFloat = 25
    
    static let topicTextFieldTag: Int = 1
    static let tagTextFieldTag: Int = 2
    static let conversationPhotoTag: Int = 3
}
