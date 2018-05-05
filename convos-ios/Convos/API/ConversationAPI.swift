//
//  ConversationAPI.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/26/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ConversationAPI: NSObject {
    static func updateConversation(
        conversationUUID: String,
        newConversationTopic: String?,
        newTagUUID: String?,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateConversationURL(conversationUUID: conversationUUID)
        var params: [String: Any] = [:]
        if let topic = newConversationTopic {
            params["topic"] = topic
        }
        if let tagUUID = newTagUUID {
            params["taguuid"] = tagUUID
        }
        Alamofire.request(
            url,
            method: .put,
            parameters: params,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating group photo: \(res.error)")
                    if res.response?.statusCode != 200 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(false)
                        }
                    }
                }
        }
    }
    
    static func updateConversationPhoto(
        conversationUUID: String,
        photo: UIImage,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateConversationPhotoURL(conversationUUID: conversationUUID)
        Alamofire.request(
            url,
            method: .put,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating group photo: \(res.error)")
                    if res.response?.statusCode != 200 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(false)
                        }
                    }
                }
        }
    }
    
    static func getTags(
        conversationUUID: String,
        searchText: String?,
        maxTags: Int?,
        completion: (@escaping ([Tag]?) -> Void)) {
    }
    
    static func createConversation(
        groupUUID: String,
        topic: String,
        photo: UIImage?,
        tagNames: [String],
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.createConversationURL()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let photo = photo, let imageData = UIImagePNGRepresentation(photo) {
                multipartFormData.append(imageData, withName: "image.png", mimeType: "image/png")
            }
            multipartFormData.append(groupUUID.data(using: .utf8)!, withName: Constants.groupUUIDParam)
            multipartFormData.append(topic.data(using: .utf8)!, withName: Constants.topicParam)
            do {
                let tagNameData = try JSON(tagNames).rawData(options: .prettyPrinted)
                multipartFormData.append(tagNameData, withName: Constants.tagNamesParam)
            } catch {
                print("Could not create array of tags UUIDs")
            }
        }, to: url,
           headers: APIHeaders.defaultHeaders()) { res in
            switch res {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    if response.result.value != nil{
                        DispatchQueue.main.async {
                            if(response.response?.statusCode != 200){
                                completion(true)
                            } else{
                                completion(false)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            case .failure:
                APIHeaders.resetAccessToken{ _ in
                    completion(false)
                }
            }
        }
    }
    
}

private struct Constants {
    static let topicParam = "topic"
    static let groupUUIDParam = "groupuuid"
    static let tagNamesParam = "tagnames"
}
