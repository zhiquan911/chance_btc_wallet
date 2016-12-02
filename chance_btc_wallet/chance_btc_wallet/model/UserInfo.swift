//
//  UserInfo.swift
//  Chance_wallet
//
//  Created by Chance on 16/5/17.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInfo: NSObject {
    
    var userId: String = ""
    var nickName: String = ""
    var address: String = ""
    var pubkey: String = ""
    var avatarUrl: String = ""

    convenience init(json: JSON) {
        self.init()
        self.userId = json["userId"].stringValue
        self.nickName = json["nickName"].stringValue
        self.address = json["address"].stringValue
        self.pubkey = json["pubkey"].stringValue
        self.avatarUrl = json["avatarUrl"].stringValue
    }
    
}
