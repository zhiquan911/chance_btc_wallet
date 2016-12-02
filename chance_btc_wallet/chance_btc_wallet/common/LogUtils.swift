//
//  LogUtils.swift
//  Chance_wallet
//
//  Created by Chance on 16/8/14.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import Log

let Log = setupAppLog()

/**
 配置一个App输出日志管理实例
 
 - returns:
 */
func setupAppLog() -> Logger {
    let applog = Logger(formatter: .Simple, theme: .default)
    #if DEBUG
        applog.enabled = true
    #else
        applog.enabled = false
    #endif
    return applog
}

// MARK: - 扩展输出格式
extension Formatters {
    
    public static let Simple = Formatter("[%@] : %@", [.location, .message])
    
}
