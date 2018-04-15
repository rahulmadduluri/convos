//
//  LoginViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginUIComponentDelegate, NewUserVCDelegate {

    var loginVCDelegate: LoginVCDelegate?
    
    fileprivate var containerView: MainLoginView? = nil
    fileprivate let socketManager: SocketManager = SocketManager.sharedInstance
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogin()
    }
    
    override func loadView() {        
        containerView = MainLoginView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.loginVC = self
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: LoginUIComponentDelegate
    
    func loginTapped() {
        // Set access token & create web socket if successfully authenticated
        MyAuth.authenticate(completion: { accessToken in
            guard let accessToken = accessToken else {
                let alert = UIAlertController(title: "Failed to authenticate", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                self.present(alert, animated: true)
                return
            }
            
            MyAuth.fetchUserInfoFromRemote(accessToken: accessToken) { uuid, phoneNumber in
                if let uuid = uuid, let mobileNumber = phoneNumber {
                    UserAPI.getUser(uuid: uuid) { user in
                        if let user = user {
                            // Found user
                            MyAuth.registerUserInfo(accessToken: accessToken, uuid: uuid, mobileNumber: mobileNumber, name: user.name, handle: user.handle, photoURI: user.photoURI)
                            self.dismiss(animated: false, completion: nil)
                        } else {
                            // Couldn't find user in database. Create new user!
                            let newUserVC = NewUserViewController(uuid: uuid, mobileNumber: mobileNumber)
                            newUserVC.newUserVCDelegate = self
                            self.present(newUserVC, animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Failed to get user info", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                    self.present(alert, animated: true)
                }
            }
        })
    }
        
    // MARK: NewUserVCDelegate
    
    func userCreated(uuid: String, mobileNumber: String, name: String, handle: String, photoURI: String?) {
        MyAuth.fetchAccessToken{ accessToken in
            if let accessToken = accessToken {
                MyAuth.registerUserInfo(accessToken: accessToken, uuid: uuid, mobileNumber: mobileNumber, name: name, handle: handle, photoURI: photoURI)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: Private
    
    fileprivate func configureLogin() {
    }
}
