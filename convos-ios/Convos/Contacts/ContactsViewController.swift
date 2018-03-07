//
//  ContactsViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/6/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, SmartTextFieldDelegate, ContactsComponentDelegate {
    
    var contactsViewData: [ContactViewData] = []
    
    fileprivate var containerView: MainContactsView? = nil
    fileprivate var panGestureRecognizer = UIPanGestureRecognizer()
    // contact table
    fileprivate var contactsTableVC = ContactsTableViewController()
    
    var contactSearchText: String? {
        return containerView?.contactTextField.text
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
    
    
    // MARK: ContactsComponentDelegate
    
    func getContactsViewData() -> [ContactViewData] {
        return contactsViewData
    }
    
    func contactSearchUpdated() {
        self.containerView?.contactTextField.showLoadingIndicator()
        fetchPotentialContacts()
    }
    
    func resetContacts() {
        fetchContacts()
        contactsTableVC.reloadContactsViewData()
    }
    
    func contactStatusSelected(cvd: ContactViewData) {
        if cvd.status == .contactNew {
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
        containerView?.contactTextField.smartTextFieldDelegate = self
        contactsTableVC.contactsVC = self
        resetTextFields()
        resetContacts()
        
        panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    fileprivate func fetchContacts() {
        if let userUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = contactSearchText ?? ""
            UserAPI.getContacts(userUUID: userUUID, searchText: searchText, maxContacts: nil, completion: { contacts in
                if let c = contacts {
                    self.receivedCurrentContacts(contacts: c)
                }
            })
        }
    }
    
    fileprivate func fetchPotentialContacts() {
        if let userUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
            let searchText = contactSearchText ?? ""
            UserAPI.getPeople(userUUID: userUUID, searchText: searchText, maxUsers: nil, completion: { allUsers in
                if let allUsers = allUsers {
                    self.receivedPotentialContacts(potentialContacts: allUsers)
                }
            })
        }
    }
    
    fileprivate func receivedCurrentContacts(contacts: [User]) {
        contactsViewData = createContactsViewData(contacts: contacts)
        contactsTableVC.reloadContactsViewData()
        containerView?.contactTextField.stopLoadingIndicator()
    }
    
    // Get all potential contacts, and separate them into old & new
    fileprivate func receivedPotentialContacts(potentialContacts: [User]) {
        var allContactsViewData = createContactsViewData(contacts: potentialContacts, status: .contactNew)
        for cvd in allContactsViewData {
            // if existing memberViewData matches (current group overlaps w/ potential member)
            if var matchingContact = contactsViewData.filter({ $0.uuid == cvd.uuid }).first {
                // update status of view data to contactExists
                allContactsViewData = allContactsViewData.filter{ $0.uuid != cvd.uuid }
                matchingContact.status = .contactExists
                allContactsViewData.append(matchingContact)
            }
        }
        contactsViewData = allContactsViewData
        contactsTableVC.reloadContactsViewData()
        containerView?.contactTextField.stopLoadingIndicator()
    }
    
    fileprivate func createContactsViewData(contacts: [User], status: ContactViewStatus = .normal) -> [ContactViewData] {
        return contacts.map({ c -> ContactViewData in
            return ContactViewData(uuid: c.uuid, text: c.name, status: status, photoURI: c.photoURI)
        })
    }
    
    fileprivate func resetTextFields() {
        containerView?.contactTextField.text = ""
    }
}
