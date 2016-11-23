//
//  PageModule.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/21.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation

/**
 *  页数结构体
 */
struct PageModule {
    var offset: Int =  20         //当前索引
    var pageSize: Int = 20        //分页大小
    var totalSize: Int = 0
}