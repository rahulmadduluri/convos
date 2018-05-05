//
//  Authenticate.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Auth0

class MyAuth: NSObject {
    
    private static let _UserAccount = "user_account"
    private static let _AccessToken = "access_token"
    private static let _RefreshToken = "refresh_token"
    
    static let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    // pass access token if true, nil otherwise
    static func authenticate(completion: @escaping (String?)->Void) {
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
            .audience("localhost:8000")
            .start {
                switch $0 {
                case .failure(let error):
                    print("Auth0: failed to authenticate: \(error)")
                    completion(nil)
                case .success(let credentials):
                    // Auth0 will automatically dismiss the login page
                    let storedSuccessfully = credentialsManager.store(credentials: credentials)
                    if storedSuccessfully == false {
                        print("Auth0: Failed to store credentials on authenticate :(")
                        completion(nil)
                    } else {
                        completion(credentials.accessToken)
                    }
                }
        }
    }
    
    // pass access token if true, nil otherwise
    static func reauthenticate(completion: @escaping (String?)->Void) {
        credentialsManager.credentials { (error, credentials) in
            guard let credentials = credentials,
                let refreshToken = credentials.refreshToken, error == nil else {
                    let removedCredentials = MyAuth.logout()
                    print("Auth0: Removed Credentials: \(removedCredentials) failed to get refresh token")
                    completion(nil)
                    return
            }
            Auth0
                .authentication()
                .renew(withRefreshToken: refreshToken)
                .start { result in
                    switch(result) {
                    case .failure(let error):
                        print("Auth0: Re-auth FAILED: Error: \(error)")
                    case .success(let credentials):
                        let storedSuccessfully = credentialsManager.store(credentials: credentials)
                        if storedSuccessfully == false {
                            let removedCredentials = MyAuth.logout()
                            print("Auth0: Removed Credentials: \(removedCredentials) Error: \(error)")
                            completion(nil)
                        } else {
                            
                            completion(credentials.accessToken)
                        }
                    }
            }
        }
    }
    
    // grab access token from credential manager
    static func fetchAccessToken(completion: @escaping (String?)->Void) {
        credentialsManager.credentials { (error, credentials) in
            guard let credentials = credentials,
                let accessToken = credentials.accessToken, error == nil else {
                    let removedCredentials = MyAuth.logout()
                    print("Auth0: Removed Credentials: \(removedCredentials) failed to fetch access token")
                    completion(nil)
                    return
            }
            completion(accessToken)
        }
    }
    
    // fetches UUID & phone # from Auth0. returns nil if failed to retrieve
    static func fetchUserInfoFromRemote(accessToken: String, completion: @escaping (String?, String?)->Void) {
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success(let profile):
                    guard let customClaims = profile.customClaims,
                        let claimUUID = customClaims["https://zebi.com/uuid"] as? String,
                        let rawNumber = profile.name else {
                        print("Auth0: profile didn't have a uuid")
                        completion(nil, nil)
                        return
                    }
                    let phoneNumber = rawNumber.replacingOccurrences(of: "+", with: "")
                    completion(claimUUID, phoneNumber)
                case .failure(let error):
                    print("Auth0: Failed to grab user profile \(error)")
                    completion(nil, nil)
                }
        }
    }
    
    // setup all local auth info -- create secure header, web socket, and store
    static func registerUserInfo(accessToken: String, uuid: String, mobileNumber: String, name: String, handle: String, photoURI: String?) {
        UserDefaults.standard.set(uuid, forKey: "uuid")
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(handle, forKey: "handle")
        UserDefaults.standard.set(photoURI, forKey: "photo_uri")
        UserDefaults.standard.set(mobileNumber, forKey: "mobile_number")
        APIHeaders.setAccessToken(accessToken: accessToken)
        SocketManager.sharedInstance.createWebSocket(accessToken: accessToken)
    }
    
    static func logout() -> Bool {
        SocketManager.sharedInstance.webSocket?.close()
        UserDefaults.standard.set("", forKey: "uuid")
        UserDefaults.standard.set("", forKey: "name")
        UserDefaults.standard.set("", forKey: "handle")
        UserDefaults.standard.set("", forKey: "photo_uri")
        UserDefaults.standard.set("", forKey: "mobile_number")
        APIHeaders.reset()
        let successfulLogout = MyAuth.credentialsManager.clear()
        if successfulLogout == false {
            print("ERROR: Failed to clear credentials")
        }
        return successfulLogout
    }

}
