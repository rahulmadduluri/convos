//
//  GroupInfoProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

enum MemberViewMode {
    case viewing
    case modifying
}

enum MemberViewStatus {
    case normal
    case memberExists
    case memberNew
    case memberRemovable
}

protocol GroupInfoVCDelegate {    
    func groupCreated()
}

protocol MemberTableVCProtocol {
    func reloadMemberViewData()
}

protocol GroupInfoComponentDelegate {
    var isNewGroup: Bool { get }
    
    func getMemberViewData() -> [MemberViewData]
    func getGroup() -> Group?
    func groupPhotoEdited(image: UIImage)
    func groupNameEdited(name: String)
    func memberSearchUpdated()
    func resetMembers()
    func memberStatusSelected(mvd: MemberViewData)
    func groupCreated(name: String?, photo: UIImage?)
    func presentAlertOption(tag: Int)
}

protocol GroupInfoUIComponent {
    var groupInfoVC: GroupInfoComponentDelegate? { get set }
}

struct MemberViewData: Hashable, Equatable {
    var uuid: String
    var text: String
    var status: MemberViewStatus
    var photoURI: String?
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
    init(uuid: String, text: String, status: MemberViewStatus, photoURI: String?) {
        self.uuid = uuid
        self.text = text
        self.status = status
        self.photoURI = photoURI
    }
}

func ==(lhs: MemberViewData, rhs: MemberViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}
