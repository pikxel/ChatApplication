//
//  User.swift
//  ChatApplication
//
//  Created by Peter Lizak on 08/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit

class User: NSObject {
    @objc var id: String?
    @objc var email: String?
    @objc var name: String?
    @objc var profileImageURL: String?
    
    init(_ userID:String,_ dictionary:[String:Any]) {
        super.init()
        id = userID
        email = dictionary["email"] as? String
        name = dictionary["name"] as? String
        profileImageURL = dictionary["profileImageURL"] as? String
    }
}
