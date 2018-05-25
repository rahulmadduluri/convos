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
                    if res.response?.statusCode == 401 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(false)
                        }
                    } else {
                        completion(false)
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
                    if res.response?.statusCode == 401 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(false)
                        }
                    } else {
                        completion(false)
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
                                completion(false)
                            } else{
                                completion(true)
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
    
    static func createMessage(
        groupUUID: String,
        allText: String,
        parentUUID: String?,
        conversationUUID: String,
        senderPhotoURI: String,
        completion: (@escaping (Message?) -> Void)) {
        let url = REST.createMessageURL(conversationUUID: conversationUUID)
        var params: [String: Any] = [:]
        params["groupuuid"] = groupUUID
        params["alltext"] = allText
        params["conversationuuid"] = conversationUUID
        params["senderphotouri"] = senderPhotoURI
        if let parentUUID = parentUUID {
            params["parentuuid"] = parentUUID
        }
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .responseJSON { res in
                if res.error == nil {
                    completion(convertResponseToMessage(res: res))
                } else {
                    print("Error while creating message: \(res.error)")
                    if res.response?.statusCode == 401 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                }
        }
    }
    
    static func getMessages(
        groupUUID: String,
        conversationUUID: String,
        lastXMessages: Int,
        latestTimestampServer: Int?,
        completion: (@escaping ([Message]?) -> Void)) {
        let url = REST.getMessagesURL(conversationUUID: conversationUUID)
        var params: [String: Any] = [:]
        params["groupuuid"] = groupUUID
        params["conversationuuid"] = conversationUUID
        params["lastxmessages"] = lastXMessages
        if let lts = latestTimestampServer {
            params["latesttimestampserver"] = lts
        }
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .responseJSON { res in
                if res.error == nil {
                    completion(convertResponseToMessages(res: res))
                } else {
                    print("Error while getting messages: \(res.error)")
                    if res.response?.statusCode == 401 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                }
        }
    }
    
    // MARK: Private
    
    private static func convertResponseToMessage(res: Alamofire.DataResponse<Any>) -> Message? {
        guard res.result.isSuccess else {
            print("Error while fetching message: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let mJSON = JSON(data: res.data!)
            return Message(json: mJSON)
        }
        return nil
    }
    
    private static func convertResponseToMessages(res: Alamofire.DataResponse<Any>) -> [Message]? {
        guard res.result.isSuccess else {
            print("Error while fetching messages: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let jsonArray = JSON(data: res.data!)
            var messages: [Message] = []
            for (_, mRaw) in jsonArray {
                if let m = Message(json: mRaw) {
                    messages.append(m)
                }
            }
            return messages
        }
        return nil
    }
    
}

private struct Constants {
    static let topicParam = "topic"
    static let groupUUIDParam = "groupuuid"
    static let tagNamesParam = "tagnames"
}
