//
//  MainLoginView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MainLoginView: UIView, UITextFieldDelegate {
    
    var loginVC: LoginUIComponentDelegate? = nil
    var logoImageView = UIImageView()
    var loginButton = UIButton()
    
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
        
        // configure image view
        logoImageView.frame = CGRect(x: self.bounds.midX - Constants.logoPhotoRadius/2, y: self.bounds.minY + Constants.logoPhotoOriginY, width: Constants.logoPhotoRadius, height: Constants.logoPhotoRadius)
        logoImageView.layer.cornerRadius = Constants.logoPhotoCornerRadius
        logoImageView.layer.masksToBounds = true
        logoImageView.image = UIImage(named: "capybara")
        self.addSubview(logoImageView)
        
        // LoginButton
        loginButton.frame = CGRect(x: self.bounds.midX - Constants.loginButtonRadius/2, y: self.bounds.minY + Constants.loginButtonOriginY, width: Constants.loginButtonRadius, height: Constants.loginButtonRadius)
        loginButton.setImage(UIImage(named: "rocket_launch"), for: .normal)
        loginButton.addTarget(self, action: #selector(MainLoginView.tapLogin(_:)), for: .touchUpInside)
        self.addSubview(loginButton)
        
    }
    
    // MARK: Gesture Recognizer functions
    
    func tapLogin(_ obj: Any) {
        loginVC?.loginTapped()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
}

private struct Constants {
    static let logoPhotoOriginY: CGFloat = 75
    static let logoPhotoRadius: CGFloat = 80
    static let logoPhotoCornerRadius: CGFloat = 40
    
    static let loginButtonOriginY: CGFloat = 600
    static let loginButtonRadius: CGFloat = 40
}
