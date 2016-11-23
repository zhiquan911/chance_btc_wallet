//
//  MessageModule.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/20.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 *  消息结构体
 */
struct MessageModule {
    var code: String = ""            //返回代码
    var message: String = ""        //返回提示信息
    var isCache: Bool = false   //是否本地缓存
    var method: String = ""
    
    init(code: String, message: String, method: String = "", isCache: Bool? = false) {
        self.code = code
        self.message = message
        self.isCache = isCache!
        self.method = method
    }
    
    init(json: JSON) {
        self.code = json["code"].stringValue
        self.message = json["message"].stringValue
        self.method = json["method"].stringValue
    }
}
