//
//  LocalizeUtils.swift
//  Chance_wallet
//
//  Created by Chance on 16/8/14.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import Localize_Swift


/**
 获取当前系统的语言
 下面是打印出当前设备支持的所有语言:(当前语言为英文)
 (en-US, zh-Hans-US.....)
 */
func GetCurrentLanguage() -> Language {
    let defs = UserDefaults.standard
    let languages = defs.object(forKey: "AppleLanguages")
    let preferredLang = (languages! as AnyObject).object(at: 0)
    Log.debug("当前系统语言:\(preferredLang)")
    
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return Language.english             //英文币种名
    case "zh-Hans-US":
        return Language.chinese_Simple             //中文币种名
    default:
        return Language.chinese_Simple
    }
}
