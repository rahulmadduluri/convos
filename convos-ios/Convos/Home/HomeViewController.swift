//
//  HomeViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/28/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, LoginVCDelegate, SearchVCDelegate, ConversationVCDelegate, GroupInfoVCDelegate, ConversationInfoVCDelegate {
    
    var loginVC: LoginViewController?
    var searchVC: SearchViewController?
    var conversationVC: ConversationViewController?
    var groupInfoVC: GroupInfoViewController?
    var conversationInfoVC: ConversationInfoViewController?
    var contactsVC: ContactsViewController?
    var userInfoVC: UserInfoViewController?
    
    private var hasBeenDisplayed = false
    
    var isLoggedIn: Bool {
        return Credentials.credentialsManager.hasValid()
    }
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHome()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasBeenDisplayed == false {
            hasBeenDisplayed = true
            if isLoggedIn == true {
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
        let successfulLogout = Credentials.credentialsManager.clear()
        if successfulLogout == true {
            presentLogin()
        }
    }
    
    // MARK: Private
    
    fileprivate func configureHome() {
        // TODO: Move this to auth controller
        UserDefaults.standard.set("uuid-1", forKey: "uuid")
        UserDefaults.standard.set("Prafulla", forKey: "name")
        UserDefaults.standard.set("prafullasd", forKey: "handle")
        UserDefaults.standard.set("prafulla_prof", forKey: "photo_uri")
    }
    
    fileprivate func presentSearch() {
        if self.searchVC == nil {
            searchVC = SearchViewController()
            searchVC?.searchVCDelegate = self
        }
        
        if let newVC = self.searchVC {
            self.presentOverHome(vc: newVC, animated: false)
        }
    }
    
    fileprivate func presentLogin() {
        if self.loginVC == nil {
            loginVC = LoginViewController()
            loginVC?.loginVCDelegate = self
        }
        
        if let newVC = self.loginVC {
            self.presentOverHome(vc: newVC, animated: false)
        }
    }
    
    fileprivate func presentOverHome(vc: UIViewController, animated: Bool) {
        vc.modalPresentationStyle = .overCurrentContext
        
        if let currentVC = presentedViewController {
            currentVC.dismiss(animated: false, completion: {
                self.present(vc, animated: animated, completion: nil)
            })
        } else {
            self.present(vc, animated: animated, completion: nil)
        }
    }
    
}
