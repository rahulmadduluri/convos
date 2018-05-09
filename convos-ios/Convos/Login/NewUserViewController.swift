//
//  NewUserViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/15/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController, NewUserUIComponentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var newUserVCDelegate: NewUserVCDelegate? = nil
    
    fileprivate var uuid: String
    fileprivate var mobileNumber: String
    fileprivate var containerView: MainNewUserView? = nil
    fileprivate var imagePicker = UIImagePickerController()
    
    init(uuid: String, mobileNumber: String) {
        self.uuid = uuid
        self.mobileNumber = mobileNumber
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNewUser()
    }
    
    override func loadView() {
        containerView = MainNewUserView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView?.newUserVC = self
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: NewUserUIComponentDelegate
    
    func createUserTapped() {
        if let name = containerView?.nameTextField.text,
            let handle = containerView?.handleTextField.text,
            let number = containerView?.mobileNumberTextField.text {
            UserAPI.createUser(name: name, handle: handle, mobileNumber: number, photo: containerView?.userPhotoImageView.image) { success in
                if success == true {
                    UserAPI.getUser(uuid: self.uuid) { user in
                        if let user = user {
                            self.newUserVCDelegate?.userCreated(uuid: self.uuid, mobileNumber: self.mobileNumber, name: name, handle: handle, photoURI: user.photoURI)
                            self.dismiss(animated: false, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Failed to get newly created user", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "User with mobile number or handle already exists", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                    self.present(alert, animated: true)
                }
            }
        } else {
            let alert = UIAlertController(title: "Failed to create user", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
            self.present(alert, animated: true)
        }
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
    
    // MARK: Private
    
    fileprivate func configureNewUser() {
        resetTextFields()
        
        containerView?.userPhotoImageView.image = UIImage(named: "capybara")
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        }
    }
    
    fileprivate func resetTextFields() {
        containerView?.mobileNumberTextField.text = mobileNumber
        containerView?.nameTextField.text = ""
        containerView?.handleTextField.text = ""
    }
    
}
