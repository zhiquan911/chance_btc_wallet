//
//  UILabel+extension.swift
//  Chance_wallet
//
//  Created by Chance on 15/12/6.
//  Copyright © 2015年 Chance. All rights reserved.
//

import Foundation

extension UILabel {
    
    public func setDecimalStr(
        _ number: String,
        color: UIColor?
        ) {
            self.text = number
            if number.range(of: ".") != nil && color != nil {
                let colorDict: [String: AnyObject] = [NSForegroundColorAttributeName: color!]
                
                let re_range = number.range(of: ".")!
                let index: Int = number.characters.distance(from: number.startIndex, to: re_range.lowerBound)
                let last = number.length
                let length = last - index
                let newRange = NSMakeRange(index, length)
                let attributedStr = NSMutableAttributedString(string: number)
                
                if newRange.location + newRange.length <= attributedStr.length  {
                    attributedStr.addAttributes(colorDict, range: newRange)
                }
                
                self.attributedText = attributedStr;
            }
    }
}
