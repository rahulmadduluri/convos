//
//  HomeViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/28/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

// Home View Controller acts as a Routing VC for all other major VCs (some of which will present their own VCs)
class HomeViewController: UIViewController, LoginVCDelegate, SearchVCDelegate, ConversationVCDelegate, GroupInfoVCDelegate, ConversationInfoVCDelegate, UserInfoVCDelegate {
    
    var loginVC: LoginViewController?
    var searchVC: SearchViewController?
    var conversationVC: ConversationViewController?
    var groupInfoVC: GroupInfoViewController?
    var conversationInfoVC: ConversationInfoViewController?
    var contactsVC: ContactsViewController?
    var userInfoVC: UserInfoViewController?
    
    // TODO: remove?
    private var hasBeenDisplayed = false
    
    fileprivate let socketManager: SocketManager = SocketManager.sharedInstance
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasBeenDisplayed == false {
            hasBeenDisplayed = true
            if MyAuth.isLoggedIn() {
                presentSearch()
            } else {
                presentLogin()
            }
        }
    }
    
    override func loadView() {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundView.backgroundColor = UIColor.clear
        self.view = backgroundView
    }
    
    // MARK: LoginVCDelegate
    
    func loggedIn() {
        presentSearch()
    }
    
    // MARK: SearchVCDelegate
    
    func createConvo(group: Group) {
        if self.conversationInfoVC == nil {
            conversationInfoVC = ConversationInfoViewController()
            conversationInfoVC?.conversationInfoVCDelegate = self
        }
        conversationInfoVC?.setConversationInfo(conversation: nil, groupUUID: group.uuid)
        
        if let newVC = self.conversationInfoVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    func convoSelected(conversation: Conversation) {
        if self.conversationVC == nil {
            self.conversationVC = ConversationViewController()
        }
        conversationVC?.setConversationInfo(uuid: conversation.uuid, groupUUID: conversation.groupUUID, newTitle: conversation.topic)
        
        if let newVC = self.conversationVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    func createGroup() {
        if self.groupInfoVC == nil {
            self.groupInfoVC = GroupInfoViewController()
            groupInfoVC?.groupInfoVCDelegate = self
        }
        groupInfoVC?.setGroupInfo(group: nil)
        
        if let newVC = self.groupInfoVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    func groupSelected(group: Group) {
        if self.groupInfoVC == nil {
            self.groupInfoVC = GroupInfoViewController()
            groupInfoVC?.groupInfoVCDelegate = self
        }
        groupInfoVC?.setGroupInfo(group: group)

        if let newVC = self.groupInfoVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    func showContacts() {
        if self.contactsVC == nil {
            self.contactsVC = ContactsViewController()
        }
        
        if let newVC = self.contactsVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    func showProfile() {
        if self.userInfoVC == nil {
            self.userInfoVC = UserInfoViewController()
            self.userInfoVC?.userInfoVCDelegate = self
        }
        
        if let newVC = self.userInfoVC {
            if self.presentedViewController == searchVC {
                searchVC?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: GroupInfoVCDelegate
    
    func groupCreated() {
        self.groupInfoVC?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: ConversationInfoVCDelegate
    
    func conversationCreated() {
        self.conversationInfoVC?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UserInfoVCDelegate
    
    func logout() {
        self.userInfoVC?.dismiss(animated: false) {
            let successfulLogout = MyAuth.logout()
            if successfulLogout == false {
                print("ERROR: Failed to clear credentials")
            }
            self.presentLogin()
        }
    }
    
    // MARK: Private
    
    fileprivate func configureHome() {
        // Nothing right now. Maybe create socket here?
    }
    
    fileprivate func presentSearch() {
        if self.searchVC == nil {
            searchVC = SearchViewController()
            searchVC?.searchVCDelegate = self
        }
        
        if let newVC = self.searchVC {
            self.dismissVCAndPresent(vc: newVC, animated: false)
        }
    }
    
    fileprivate func presentLogin() {
        if self.loginVC == nil {
            loginVC = LoginViewController()
            loginVC?.loginVCDelegate = self
        }
        
        if let newVC = self.loginVC {
            self.dismissVCAndPresent(vc: newVC, animated: false)
        }
    }
    
    fileprivate func dismissVCAndPresent(vc: UIViewController, animated: Bool) {
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: false) {
                self.present(vc, animated: animated, completion: nil)
            }
        } else {
            self.present(vc, animated: animated, completion: nil)
        }
    }
    
}
