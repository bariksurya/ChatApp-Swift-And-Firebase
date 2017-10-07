//
//  Message.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/30/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import FirebaseAuth

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?

    func chatPartnerId() -> String {
        return (fromId == Auth.auth().currentUser?.uid ? toId : fromId)!
    }
 
}

