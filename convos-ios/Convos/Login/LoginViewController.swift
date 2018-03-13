//
//  LoginViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Auth0

class LoginViewController: UIViewController, LoginUIComponentDelegate {
    
    var loginVCDelegate: LoginVCDelegate?
    
    fileprivate var containerView: MainLoginView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogin()
    }
    
    override func loadView() {        
        containerView = MainLoginView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.addGestureRecognizer(panGestureRecognizer)
        containerView?.loginVC = self
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            if (translation.x > 150) {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: LoginUIComponentDelegate
    
    func loginTapped() {
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
            .audience("https://zebi.auth0.com/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the login page
                    let storedSuccessfully = Credentials.credentialsManager.store(credentials: credentials)
                    if storedSuccessfully == false {
                        print("Failed to store credentials :(")
                    } else {
                        guard let accessToken = credentials.accessToken else {
                            print("Access token wasn't available")
                            break
                        }
                        // attach access token to networking for headers
                    }
                    self.dismiss(animated: false, completion: nil)
                }
        }
    }
    
    // MARK: Private
    
    fileprivate func configureLogin() {
    }
}
