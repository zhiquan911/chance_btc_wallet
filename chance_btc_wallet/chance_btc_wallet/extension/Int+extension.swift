//
//  Int+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/6/7.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension Int {
    
    /**
     转化为字符串格式
     - returns:
     */
    func toString() -> String {
        return String(self)
    }
    
    /**
     把布尔变量转化为Int
     - returns:
     */
    init(_ value: Bool) {
        if value {
            self.init(1)
        } else {
            self.init(0)
        }
    }
    
    /// 转为浮点型
    ///
    /// - Returns:
    func toFloat() -> Float {
        return Float(self)
    }
    
    /// 系统的整数型是否使用little-endian方式编码
    /// swift默认使用littlt-endian字节序
    public static var isLittleEndian: Bool {
        return Int(littleEndian: 42) == 42
    }
}


extension Int64 {
    
    /**
     转化为字符串格式
     - returns:
     */
    func toString() -> String {
        return String(self)
    }
    
    
    /// 转为浮点型
    ///
    /// - Returns: 
    func toFloat() -> Float {
        return Float(self)
    }
    
    /**
     把布尔变量转化为Int
     - returns:
     */
    init(_ value: Bool) {
        if value {
            self.init(1)
        } else {
            self.init(0)
        }
    }
}
