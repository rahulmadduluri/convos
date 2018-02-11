//
//  HomeViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/28/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, SearchVCDelegate {
    var containerView: MainHomeView? = nil

    var searchVC = SearchViewController()
     // conversation VC to transition to
    var conversationVC: ConversationViewController?
    var groupInfoVC: GroupInfoViewController?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHome()
    }
        
    override func loadView() {
        self.addChildViewController(searchVC)
        
        containerView = MainHomeView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.searchContainerView = searchVC.view
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: SearchVCDelegate
    
    func createConvo(group: Group) {
        // present convo created view controller
    }
    
    func convoSelected(conversation: Conversation) {
        if self.conversationVC == nil {
            self.conversationVC = ConversationViewController()
        }
        conversationVC?.setConversationInfo(uuid: conversation.uuid, newTitle: conversation.topic)
        
        if let newVC = self.conversationVC {
            self.present(newVC, animated: false, completion: nil)
        }
    }
    
    func createGroup() {
        if self.groupInfoVC == nil {
            self.groupInfoVC = GroupInfoViewController()
        }
        groupInfoVC?.setGroupInfo(group: nil)
        
        if let newVC = self.groupInfoVC {
            self.present(newVC, animated: false, completion: nil)
        }
    }
    
    func groupSelected(group: Group) {
        // present group info view controller
    }
    
    // MARK: Private
    
    fileprivate func configureHome() {
        // TODO: Move this to auth controller
        UserDefaults.standard.set("uuid-1", forKey: "uuid")
        
        searchVC.searchVCDelegate = self
    }
    
}
