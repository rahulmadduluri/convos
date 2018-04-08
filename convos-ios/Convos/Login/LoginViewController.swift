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
        MyAuth.authenticate(onSuccess: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: Private
    
    fileprivate func configureLogin() {
    }
}
