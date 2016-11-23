//
//  UnspentTransaction.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/26.
//  Copyright © 2016年 bitbank. All rights reserved.
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
