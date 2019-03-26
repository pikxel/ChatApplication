//
//  Message.swift
//  ChatApplication
//
//  Created by Peter Lizak on 11/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    @objc var recipientUserID: String?
    @objc var senderUserID: String?
    @objc var text: String?
    @objc var imageUrl: String?
    @objc var videoUrl: String?
    @objc var timeStamp: NSNumber?
    @objc var imageHeight: NSNumber?
    @objc var imageWidth: NSNumber?
    
    init(_ dictionary:[String:Any]) {
        super.init()
        senderUserID = dictionary["senderUserID"] as? String
        recipientUserID = dictionary["recipientUserID"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        videoUrl = dictionary["videoUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }

    func getRecipiantUserID() -> String? {
        return Auth.auth().currentUser?.uid == self.senderUserID ? self.recipientUserID : self.senderUserID
    }
}
