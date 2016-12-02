//
//  Float+extension.swift
//  Chance_wallet
//
//  Created by Chance on 15/12/24.
//  Copyright © 2015年 Chance. All rights reserved.
//

import Foundation

extension Float {
    
   static func str(_ str: String) -> Float {
        var mstr = str
        if mstr == "" {
            mstr = "0"
        }
        return self.init(mstr)!
    }
    
    /**
     向下取第几位小数
     
     - parameter places: 第几位小数 ，1
     
     15.96 * 10.0 = 159.6
     floor(159.6) = 159.0
     159.0 / 10.0 = 15.9
     
     - returns:  15.96 =  15.9
     */
    func f(_ places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return floor(self * divisor) / divisor
    }
    
    /**
     向下取第几位小数
     
     - parameter places: 第几位小数 ，1
     
     15.96 * 10.0 = 159.6
     floor(159.6) = 159.0
     159.0 / 10.0 = 15.9
     
     - returns:  15.96 =  15.9
     */
    func toFloor(_ places:Int) -> String {
        let divisor = pow(10.0, Float(places))
        return (floor(self * divisor) / divisor).toString(maxF: places)
    }
    
    /**
     转化为字符串格式
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns: 
     */
    func toString(_ minF: Int = 2, maxF: Int = 6, minI: Int = 1) -> String {
        let valueDecimalNumber = NSDecimalNumber(value: self as Float)
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        return twoDecimalPlacesFormatter.string(from: valueDecimalNumber)!
    }
}
