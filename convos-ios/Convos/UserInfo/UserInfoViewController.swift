//
//  UserInfoViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInfo()
    }
    
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
            UserAPI.updateUser(userUUID: myUUID, name: name, handle: nil) { success in
                if success == false {
                    print("Failed to update name :( ")
                }
            }
        }
    }
    
    func userHandleEdited(handle: String) {
        let modifiedHandle = handle.replacingOccurrences(of: " ", with: "")
        if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String, isMe == true{
            UserAPI.updateUser(userUUID: myUUID, name: nil, handle: modifiedHandle) { success in
                if success == false {
                    print("Failed to update handle :( ")
                }
            }
        }
    }
    
    func presentAlertOption(tag: Int) {
        var editActionTitle: String = ""
        var updateUserTitle = "Update Profile"
        let alert = UIAlertController(title: updateUserTitle, message: "", preferredStyle: .actionSheet)
        if tag == Constants.nameTag {
            editActionTitle += "Edit Name"
            alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
                self.containerView?.beginEditPressed(tag: tag)
            })
        } else if tag == Constants.photoTag {
            editActionTitle += "Edit Photo"
            alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
                self.containerView?.beginEditPressed(tag: tag)
            })
        } else if tag == Constants.handleTag {
            editActionTitle += "Edit Handle"
            alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
                self.containerView?.beginEditPressed(tag: tag)
            })
        } else if tag == Constants.logoutTag {
            updateUserTitle = "Log Out?"
            editActionTitle = "Log Out!"
            alert.addAction(UIAlertAction(title: editActionTitle, style: .default) { action in
                self.userInfoVCDelegate?.logout()
            })
        }
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
        resetTextFields()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        }
        
        if isMe == false {
            containerView?.nameTextField.text = person!.name
            if let uri = person!.photoURI {
                var urlRequest = URLRequest(url: REST.imageURL(imageURI: uri))
                urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
                containerView?.userPhotoImageView.af_setImage(withURLRequest: urlRequest)
            }
        } else {
            if let myName = UserDefaults.standard.object(forKey: "name") as? String,
                let myHandle = UserDefaults.standard.object(forKey: "handle") as? String,
                let myPhotoURI = UserDefaults.standard.object(forKey: "photo_uri") as? String {
                containerView?.nameTextField.text = myName
                containerView?.handleTextField.text = "@" + myHandle
                var urlRequest = URLRequest(url: REST.imageURL(imageURI: myPhotoURI))
                urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
                containerView?.userPhotoImageView.af_setImage(withURLRequest: urlRequest)
            }
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func resetTextFields() {
        containerView?.nameTextField.text = ""
        containerView?.handleTextField.text = ""
    }
    
}

private struct Constants {
    static let nameTag = 1
    static let photoTag = 2
    static let handleTag = 3
    static let logoutTag = 4
}
