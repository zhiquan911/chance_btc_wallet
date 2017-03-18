//
//  userBalance.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/20.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import RealmSwift

class UserBalance: Object {

    //MARK: - 数据库的字段
    dynamic var address = ""
    dynamic var balance: Double = 0
    dynamic var balanceSat: Int = 0
    dynamic var totalReceived: Double = 0
    dynamic var totalReceivedSat: Int = 0
    dynamic var totalSent: Double = 0
    dynamic var totalSentSat: Int = 0
    dynamic var unconfirmedBalance: Double = 0
    dynamic var unconfirmedBalanceSat: Int = 0
    dynamic var unconfirmedTxApperances: Int = 0
    dynamic var txApperances: Int = 0
    dynamic var currency: String = ""
    
    //MARK: - 忽略持久化的字段
    var currencyType: CurrencyType = .BTC
    
    override static func primaryKey() -> String? {
        return "address"
    }
    
    /// 忽略建立的字段
    ///
    /// - Returns:
    override static func ignoredProperties() -> [String] {
        return [
            "currencyType"
        ]
    }
    
    
    /// 保存
    func save() {
        //保存到数据库
        let realm = RealmDBHelper.shared.txDB
        
        try? realm.write {
            realm.add(self, update: true)
        }
        
    }
    
    
    /// 获取用户余额
    ///
    /// - Parameter address: 地址
    /// - Returns: 用户余额对象
    class func getUserBalance(byAddress address: String) -> UserBalance? {
        let realm = RealmDBHelper.shared.txDB  //Realm数据库
        let datas: Results<UserBalance> = realm.objects(UserBalance.self).filter(" address = '\(address)'")
        return datas.first
    }
    
    /// 计算法币的价值
    ///
    /// - Parameter price: 单价
    /// - Returns: （余额 + 未确认） * 单价
    func getBTCBalance() -> String {
        let total = BTCAmount(self.balanceSat + self.unconfirmedBalanceSat)
        return total.toBTC()
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
