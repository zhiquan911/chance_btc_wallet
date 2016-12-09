//
//  NSNumber+extension.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/8.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

extension NSNumber {

    // MARK: - 转换方法法
    func toDecimalNumber() -> NSDecimalNumber {
        return NSDecimalNumber(decimal: self.decimalValue)
    }
}
