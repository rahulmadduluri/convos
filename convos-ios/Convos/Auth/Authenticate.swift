//
//  Authenticate.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Auth0
import Locksmith

class MyAuth: NSObject {
    
    private static let _UserAccount = "user_account"
    private static let _AccessToken = "access_token"
    private static let _RefreshToken = "refresh_token"
    
    static let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    static func authenticate(onSuccess: @escaping ()->Void) {
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
                    // Auth0 will automatically dismiss the login page
                    let storedSuccessfully = credentialsManager.store(credentials: credentials)
                    if storedSuccessfully == false {
                        print("Failed to store credentials on authenticate :(")
                    } else {
                        onSuccess()
                    }
                }
        }
    }
    
    static func reauthenticate(onSuccess: @escaping ()->Void) {
        credentialsManager.credentials { (error, credentials) in
            if error != nil {
                let removedCredentials = self.credentialsManager.clear()
                print("Removed Credentials: \(removedCredentials) Error: \(error)")
            } else {
                guard let credentials = credentials,
                    let refreshToken = credentials.refreshToken else {
                        let removedCredentials = self.credentialsManager.clear()
                        print("Removed Credentials: \(removedCredentials) failed to get refresh token")
                        return
                }
                Auth0
                    .authentication()
                    .renew(withRefreshToken: refreshToken)
                    .start { result in
                        switch(result) {
                        case .failure(let error):
                            let removedCredentials = self.credentialsManager.clear()
                            print("Removed Credentials: \(removedCredentials) Error: \(error)")
                        case .success(let credentials):
                            let storedSuccessfully = credentialsManager.store(credentials: credentials)
                            if storedSuccessfully == false {
                                let removedCredentials = self.credentialsManager.clear()
                                print("Removed Credentials: \(removedCredentials) Error: \(error)")
                            } else {
                                onSuccess()
                            }
                        }
                }
            }
        }
    }
}
