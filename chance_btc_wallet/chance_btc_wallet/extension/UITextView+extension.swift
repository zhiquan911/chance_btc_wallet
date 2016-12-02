//
//  UITextView+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/8/29.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension UITextView{
    
    /// 扩展做一个字段可以设置本地化
    @IBInspectable var localized: Bool{
        get{
            return true
        }
        set(newlocale){
            self.text = self.text.localized()
        }
    }
}
