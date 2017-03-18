//
//  WorldTicker.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/18.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit
import SwiftyJSON

class WorldTicker: NSObject {
    
    var currency: String = ""
    var legalCurrency: String = ""
    var last: Double = 0
    var buy: Double = 0
    var sell: Double = 0
    var symbol: String = "$"
    
    init(json: JSON, currency: String, legalCurrency: String) {
        self.currency = currency
        self.last = json["last"].doubleValue
        self.buy = json["buy"].doubleValue
        self.sell = json["sell"].doubleValue
        self.symbol = json["symbol"].stringValue
        self.legalCurrency = legalCurrency
    }
}
