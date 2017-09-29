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

    var searchVC = SearchViewController() // search VC
    var conversationVC: ConversationViewController? // conversation VC to transition to
    
    // MARK: UIViewController
        
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
    
    func resultSelected(result: SearchViewData) {
        if self.conversationVC == nil {
            let vc = ConversationViewController()
            vc.setConversationTitle(newTitle: result.text)
            self.conversationVC = ConversationViewController()
            
        }
        
        if let newVC = self.conversationVC {
            self.present(newVC, animated: false, completion: nil)
        }
    }
    
    func keyboardWillShow() {
        
    }
    
    func keyboardWillHide() {
        
    }
    
}
