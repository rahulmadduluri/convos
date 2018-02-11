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
    func getGroup() -> Group?
}

protocol GroupInfoUIComponent {
    var groupInfoVC: GroupInfoComponentDelegate? { get set }
}
