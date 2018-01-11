//
//  DateTimeUtilities.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class DateTimeUtilities: NSObject {
    static func minutesAgo(unixTimestamp: Int) -> Int {
        let currentTime = Int(NSDate().timeIntervalSince1970)
        let difference = unixTimestamp - currentTime
        return difference > 0 ? difference : 0
    }
    
    static func minutesAgoText(unixTimestamp: Int) -> String {
        return String(minutesAgo(unixTimestamp: unixTimestamp))
    }
}
