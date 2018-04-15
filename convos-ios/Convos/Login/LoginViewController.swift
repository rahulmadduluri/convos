//
//  LoginViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginUIComponentDelegate {
    
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
        MyAuth.authenticate(completion: { accessToken in
            
            if let token = accessToken {
                APIHeaders.setAccessToken(accessToken: token)
                self.socketManager.createWebSocket(accessToken: token)
                self.dismiss(animated: false, completion: nil)
            } else {
                let alert = UIAlertController(title: "Failed to authenticate", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                self.present(alert, animated: true)
                return
            }
            
            if 
            
            // TODO
            // instead of phone #, have Auth0 return a uuid
            // create a user in database (if does not exist) with this uuid
            // return data for user and store in NSUserDefaults
            
            // add header x-uuid and attach the uuid
            // use checkUUID function on backend to verify that the UUID passed matches the UUID encoded in the token
            
            
            
            
            
            /*
            MyAuth.fetchUserPhoneNumber { number in
                if let number = number {
                    UserAPI.getUser(mobileNumber: number) { user in
                        if let user = user {
                            UserDefaults.standard.set(user.uuid, forKey: "uuid")
                            UserDefaults.standard.set(user.name, forKey: "name")
                            UserDefaults.standard.set(user.handle, forKey: "handle")
                            UserDefaults.standard.set(user.photoURI, forKey: "photo_uri")
                            UserDefaults.standard.set(number, forKey: "mobile_number")
                        }
                        self.dismiss(animated: false, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Failed to get phone #", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Well this sucks...", style: .destructive))
                    self.present(alert, animated: true)
                    return
                }
            }
            */
        })
    }
    
    // MARK: Private
    
    fileprivate func configureLogin() {
    }
}
