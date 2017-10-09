import UIKit
import SwiftyJSON

class MessageRequest: NSObject, Model {
    
    // vars
    
    required init?(json: JSON) {
    }
    
    // Model
    func toJSON() -> JSON {
        return JSON([:])
    }
}

class MessageResponse: NSObject, Model {
    // vars
    
    // init
    required init?(json: JSON) {
        
    }
    
    // Model
    func toJSON() -> JSON {
        return JSON([:])
    }
}
