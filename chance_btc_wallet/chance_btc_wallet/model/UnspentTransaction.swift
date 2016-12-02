//
//  UnspentTransaction.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/26.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class UnspentTransaction: NSObject {

    var address = ""
    var txid = ""
    var vout: Int!
    var timestamp: Int!
    var scriptPubKey = ""
    var amount: BTCAmount!
    var confirmations: Int!
    var confirmationsFromCache: Bool!
    
}
