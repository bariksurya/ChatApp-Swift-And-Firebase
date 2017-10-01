//
//  Message.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/30/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import  Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?

    func chatPartnerId() -> String {
        return (fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId)!
    }
 
}

