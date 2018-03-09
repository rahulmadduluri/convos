//
//  UserInfoViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

import UIKit
import SwiftyJSON

class UserInfoViewController: UIViewController, SmartTextFieldDelegate, UserInfoComponentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userInfoVCDelegate: UserInfoVCDelegate? = nil
    
    fileprivate var person: User? = nil
    fileprivate var containerView: MainUserInfoView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    fileprivate var imagePicker = UIImagePickerController()
    
    var isMe: Bool {
        return person == nil
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        containerView = MainUserInfoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.addGestureRecognizer(panGestureRecognizer)
        containerView?.userInfoVC = self
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
        configureUserInfo()
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
    }
    
    
    // MARK: UserInfoComponentDelegate
    
    func getUser() -> User? {
        return person
    }
    
    func userPhotoEdited(image: UIImage) {
        if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String, isMe == true{
            UserAPI.updateUserPhoto(userUUID: myUUID, photo: image) { success in
                if success == false {
                    print("Failed to update user photo :( ")
                }
            }
        }
    }
    
    func userNameEdited(name: String) {
        if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String, isMe == true{
            UserAPI.updateUserName(userUUID: myUUID, name: name) { success in
                if success == false {
                    print("Failed to update name :( ")
                }
            }
        }
    }
    
    func presentAlertOption(tag: Int) {
        var editActionTitle: String = ""
        let updateUserTitle = "Update Profile"
        let alert = UIAlertController(title: updateUserTitle, message: "", preferredStyle: .actionSheet)
        if tag == Constants.nameTag {
            editActionTitle += "Edit Name"
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
            containerView?.userPhotoImageView.image = chosenImage
            // make edit photo request
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public
    
    func setUserInfo(user: User?) {
        self.person = user
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
    
    fileprivate func configureUserInfo() {
        containerView?.nameTextField.text = ""
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        }
        
        if isMe == false {
            containerView?.nameTextField.text = person!.name
            if let uri = person!.photoURI {
                containerView?.userPhotoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
        } else {
            if let myName = UserDefaults.standard.object(forKey: "name") as? String,
                let myPhotoURI = UserDefaults.standard.object(forKey: "photo_uri") as? String {
                containerView?.nameTextField.text = myName
                containerView?.userPhotoImageView.af_setImage(withURL: REST.imageURL(imageURI: myPhotoURI))
            }
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
}

private struct Constants {
    static let nameTag = 1
    static let photoTag = 2
}