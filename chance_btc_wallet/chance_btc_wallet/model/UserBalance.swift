//
//  userBalance.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/20.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class UserBalance: NSObject {

    var address = ""
    var balance: Double = 0
    var balanceSat: Int = 0
    var totalReceived: Double = 0
    var totalReceivedSat: Int = 0
    var totalSent: Double = 0
    var totalSentSat: Int = 0
    var unconfirmedBalance: Double = 0
    var unconfirmedBalanceSat: Int = 0
    var unconfirmedTxApperances: Int = 0
    var txApperances: Int = 0
    var currencyType: CurrencyType = .BTC
    
    
    /// 计算法币的价值
    ///
    /// - Parameter price: 单价
    /// - Returns: （余额 + 未确认） * 单价
    func getBTCBalance() -> String {
        let total = (self.balance + self.unconfirmedBalance).toString()
        return total
    }
    
    /// 计算法币的价值
    ///
    /// - Parameter price: 单价
    /// - Returns: （余额 + 未确认） * 单价
    func getLegalMoney(price: Double) -> Double {
        let total = (self.balance + self.unconfirmedBalance) * price
        return total
    }
}
