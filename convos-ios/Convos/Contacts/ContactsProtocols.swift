//
//  ContactsProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/6/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

enum ContactViewStatus {
    case normal
    case contactExists
    case contactNew
}

protocol ContactsTableVCProtocol {
    func reloadContactsViewData()
}

protocol ContactsComponentDelegate {
    func getContactsViewData() -> [ContactViewData]
    func contactSearchUpdated()
    func resetContacts()
    func contactStatusSelected(cvd: ContactViewData)
}

protocol ContactsUIComponent {
    var contactsVC: ContactsComponentDelegate? { get set }
}

struct ContactViewData: Hashable, Equatable {
    var uuid: String
    var text: String
    var status: ContactViewStatus
    var photoURI: String?
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
    init(uuid: String, text: String, status: ContactViewStatus, photoURI: String?) {
        self.uuid = uuid
        self.text = text
        self.status = status
        self.photoURI = photoURI
    }
}

func ==(lhs: ContactViewData, rhs: ContactViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}
