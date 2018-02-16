//
//  GroupInfoProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol GroupInfoVCDelegate {
    func groupCreated()
}

protocol MemberTableVCProtocol {
    func reloadMemberViewData()
}

protocol GroupInfoComponentDelegate {
    var isEditingMembers: Bool { get set }
    
    func getUserViewData() -> [UserViewData]
    func getGroup() -> Group?
    func groupNameEdited(name: String)
    func groupMembersEdited()
    func groupCreated(name: String, photo: UIImage?)
    func presentAlertOption(tag: Int)
}

protocol GroupInfoUIComponent {
    var groupInfoVC: GroupInfoComponentDelegate? { get set }
}

struct UserViewData: Hashable, Equatable {
    var uuid: String
    var text: String
    var photoURI: String?
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
    init(uuid: String, text: String, photoURI: String?) {
        self.uuid = uuid
        self.text = text
        self.photoURI = photoURI
    }
}

func ==(lhs: UserViewData, rhs: UserViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}
