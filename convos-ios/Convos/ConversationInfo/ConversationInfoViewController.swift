//
//  ConversationInfoViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/25/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConversationInfoViewController: UIViewController, SmartTextFieldDelegate, ConversationInfoComponentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // if isNewConversation == true, ConversationInfoVC is creating a new conversation
    
    var conversationInfoVCDelegate: ConversationInfoVCDelegate? = nil
    
    fileprivate var conversation: Conversation? = nil
    fileprivate var groupUUID: String = ""
    fileprivate var containerView: MainConversationInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    fileprivate var imagePicker = UIImagePickerController()
    
    var tagSearchText: String? {
        return containerView?.tagTextField.text
    }
    var isNewConversation: Bool {
        return conversation == nil
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        containerView = MainConversationInfoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.addGestureRecognizer(panGestureRecognizer)
        containerView?.conversationInfoVC = self
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureConversationInfo()
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
    }
    
    
    // MARK: ConversationInfoComponentDelegate
    
    func getConversation() -> Conversation? {
        return conversation
    }
    
    func conversationPhotoEdited(image: UIImage) {
        if isNewConversation == false{
            ConversationAPI.updateConversationPhoto(conversationUUID: conversation!.uuid, photo: image) { success in
                if success == false {
                    print("Failed to update conversation photo :( ")
                }
            }
        }
    }
    
    func conversationTopicEdited(topic: String) {
        if isNewConversation == false {
            ConversationAPI.updateConversation(conversationUUID: conversation!.uuid, newConversationTopic: topic, newTagUUID: nil) { success in
                if success == false {
                    print("Failed to update conversation topic :( ")
                } else {
                    self.conversation?.topic = topic
                }
            }
        }
    }
    
    func conversationCreated(topic: String?, photo: UIImage?, tagNames: [String]) {
        if let topic = topic,
            topic.isEmpty == false,
            isNewConversation == true {
            ConversationAPI.createConversation(groupUUID: groupUUID, topic: topic, photo: photo, tagNames: tagNames) { success in
                if success == false {
                    print("Failed to encode request for conversation :( ")
                }
                self.conversationInfoVCDelegate?.conversationCreated()
            }
        } else {
            let alert = UIAlertController(title: "Failed To Create Conversation", message: "Missing Fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .destructive))
            present(alert, animated: true)
        }
    }
    
    func tagSearchUpdated() {
        self.containerView?.tagTextField.showLoadingIndicator()
        //fetchPotentialTags()
    }
    
    func resetTags() {
        //fetchTags()
    }
    
    func presentAlertOption(tag: Int) {
        var editActionTitle: String = ""
        let conversationTopic = conversation?.topic ?? "New Convo"
        let alert = UIAlertController(title: conversationTopic, message: "", preferredStyle: .actionSheet)
        if tag == Constants.topicTag {
            editActionTitle += "Edit Topic"
        } else if tag == Constants.tagsTag {
            editActionTitle += "Add Tag"
        } else if tag == Constants.photoTag {
            editActionTitle += "Edit Photo"
        }
        alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
            self.containerView?.beginEditPressed(tag: tag)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
        
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            containerView?.conversationPhotoImageView.image = chosenImage
            // make edit photo request
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public
    
    func setConversationInfo(conversation: Conversation?, groupUUID: String) {
        self.conversation = conversation
        self.groupUUID = groupUUID
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            if (translation.x > 150) {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: Private
    
    fileprivate func configureConversationInfo() {
        containerView?.tagTextField.smartTextFieldDelegate = self
        resetTextFields()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        }
        
        if isNewConversation == false {
            containerView?.topicTextField.text = conversation!.topic
            if let uri = conversation!.photoURI {
                var urlRequest = URLRequest(url: REST.imageURL(imageURI: uri))
                urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
                containerView?.conversationPhotoImageView.af_setImage(withURLRequest: urlRequest)
            }
        } else {
            containerView?.conversationPhotoImageView.image = UIImage(named: "capybara")
            containerView?.createNewConversationButton.alpha = 1
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
        
    fileprivate func resetTextFields() {
        containerView?.topicTextField.text = ""
        containerView?.tagTextField.text = ""
    }
}

private struct Constants {
    static let topicTag = 1
    static let tagsTag = 2
    static let photoTag = 3
}
