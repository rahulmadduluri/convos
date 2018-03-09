//
//  ContactsViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/6/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, SmartTextFieldDelegate, UITextFieldDelegate, ContactsComponentDelegate {
    
    var contactsViewData: [ContactViewData] = []
    var searchMode: ContactSearchMode = .exists
    
    fileprivate var containerView: MainContactsView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    // contact table
    fileprivate var contactsTableVC = ContactsTableViewController()
    
    var contactSearchText: String? {
        return containerView?.topBarView.contactTextField.text
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        self.addChildViewController(contactsTableVC)
        
        containerView = MainContactsView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        containerView?.addGestureRecognizer(panGestureRecognizer)
        containerView?.contactsVC = self
        containerView?.contactsTableContainerView = contactsTableVC.view
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureContacts()
    }
    
    // MARK: SmartTextFieldDelegate
    
    func smartTextUpdated(smartText: String) {
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if text != "" {
            fetchPotentialContacts()
        } else {
            fetchContacts()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: ContactsComponentDelegate
    
    func getContactsViewData() -> [ContactViewData] {
        return contactsViewData
    }
    
    func resetContacts() {
        fetchContacts()
        contactsTableVC.reloadContactsViewData()
    }
    
    func contactStatusSelected(cvd: ContactViewData) {
        if cvd.status == .contactNew {
        }
    }
    
    func addContactSelected() {
        if searchMode == .exists {
            searchMode = .new
            fetchPotentialContacts()
            containerView?.topBarView.contactTextField.becomeFirstResponder()
        } else {
            searchMode = .exists
            fetchContacts()
            containerView?.topBarView.contactTextField.becomeFirstResponder()
        }
    }
    
    // MARK: Public
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            if (translation.x > 150) {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: Private
    
    fileprivate func configureContacts() {
        containerView?.topBarView.contactTextField.smartTextFieldDelegate = self
        contactsTableVC.contactsVC = self
        resetTextFields()
        resetContacts()
        
        containerView?.topBarView.contactTextField.userStoppedTypingHandler = {
            if let contactText = self.contactSearchText {
                self.containerView?.topBarView.contactTextField.showLoadingIndicator()
                if self.searchMode == .exists {
                    self.fetchContacts()
                } else if self.searchMode == .new {
                    self.fetchPotentialContacts()
                }
            }
        }
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func fetchContacts() {
        if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = contactSearchText ?? ""
            UserAPI.getContacts(userUUID: myUUID, searchText: searchText, maxContacts: nil, completion: { contacts in
                if let c = contacts {
                    self.receivedCurrentContacts(contacts: c)
                }
            })
        }
    }
    
    fileprivate func fetchPotentialContacts() {
        if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = contactSearchText ?? ""
            UserAPI.getPeople(searchText: searchText, maxUsers: nil, completion: { allUsers in
                if let allUsers = allUsers {
                    self.receivedPotentialContacts(potentialContacts: allUsers.filter{ $0.uuid != myUUID})
                }
            })
        }

    }
    
    fileprivate func receivedCurrentContacts(contacts: [User]) {
        contactsViewData = createContactsViewData(contacts: contacts)
        contactsTableVC.reloadContactsViewData()
        containerView?.topBarView.contactTextField.stopLoadingIndicator()
    }
    
    // Get all potential contacts, and separate them into old & new
    fileprivate func receivedPotentialContacts(potentialContacts: [User]) {
        var allContactsViewData = createContactsViewData(contacts: potentialContacts, status: .contactNew)
        for cvd in allContactsViewData {
            // if existing contactViewData matches (current group overlaps w/ potential member)
            if var matchingContact = contactsViewData.filter({ $0.uuid == cvd.uuid }).first {
                // update status of view data to contactExists
                allContactsViewData = allContactsViewData.filter{ $0.uuid != cvd.uuid }
                matchingContact.status = .contactExists
                allContactsViewData.append(matchingContact)
            }
        }
        contactsViewData = allContactsViewData
        contactsTableVC.reloadContactsViewData()
        containerView?.topBarView.contactTextField.stopLoadingIndicator()
    }
    
    fileprivate func createContactsViewData(contacts: [User], status: ContactViewStatus = .normal) -> [ContactViewData] {
        return contacts.map({ c -> ContactViewData in
            return ContactViewData(uuid: c.uuid, text: c.name, status: status, photoURI: c.photoURI)
        })
    }
    
    fileprivate func resetTextFields() {
        containerView?.topBarView.contactTextField.text = ""
    }
}
