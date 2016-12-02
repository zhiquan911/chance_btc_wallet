//
//  BTCAmount+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/20.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension BTCAmount {
    
    /**
     把聪类型转为浮点格式的字符
     
     - parameter satoshiAmount: 聪
     
     - returns: 浮点的字符串
     */
    public static func stringWithSatoshiInBTCFormat(_ satoshiAmount: BTCAmount) -> String {
        var BTCValueDecimalNumber = NSDecimalNumber(value: satoshiAmount as Int64)
        BTCValueDecimalNumber = BTCValueDecimalNumber.dividing(by: NSDecimalNumber(value: BTCCoin as Int64))
        
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = 10
        twoDecimalPlacesFormatter.minimumFractionDigits = 2
        twoDecimalPlacesFormatter.minimumIntegerDigits = 1
        
        return twoDecimalPlacesFormatter.string(from: BTCValueDecimalNumber)!
    }
    
    /**
     把浮点的字符串转未聪类型
     
     - parameter amountString:
     
     - returns: 
     */
    public static func satoshiWithStringInBTCFormat(_ amountString: String) -> BTCAmount {
        let amountDecimalNumber = NSDecimalNumber(string: amountString)
        let satoshiAmountDecimalNumber = amountDecimalNumber.multiplying(by: NSDecimalNumber(value: BTCCoin as Int64))
        
        let satoshiAmountInteger = satoshiAmountDecimalNumber.int64Value
        return satoshiAmountInteger
    }
}
