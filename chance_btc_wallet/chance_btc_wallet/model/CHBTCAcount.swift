//
//  BBAcounts.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/15.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import KeychainSwift
import RealmSwift

class CHBTCAcount: Object {
    
    //MARK: - 数据库字段
    dynamic var index: Int = 0                          //账户所在钱包的索引位
    dynamic var accountId: String = ""                  //用账户的地址作为id
    dynamic var redeemScriptHex: String = ""        //账户的赎回脚本
    dynamic var userNickname: String = ""                   //昵称
    dynamic var isEnable: Bool = true                   //是否可用
    dynamic var keyPath: String = ""                //HDM私钥路径，如："m/44'/0'/2'" (BIP44 bitcoin account #2)
    
    /// 获取可扩展的私钥
    var btcKeychain: BTCKeychain?
    
    override static func primaryKey() -> String? {
        return "accountId"
    }

    
    /// 忽略建立的字段
    ///
    /// - Returns:
    override static func ignoredProperties() -> [String] {
        return ["btcKeychain"]
    }
    
    /// 根据HDM钱包索引获取用户
    ///
    /// - Parameter index: 索引位
    /// - Returns: 
    class func getBTCAccount(by index: Int) -> CHBTCAcount? {
        let realm = RealmDBHelper.acountDB  //Realm数据库
        let datas: Results<CHBTCAcount> = realm.objects(CHBTCAcount.self).filter(" index = \(index)").sorted(byProperty: "index", ascending: true)
        return datas.first
    }
    
    /// 获取全部比特币账户
    ///
    /// - Returns:
    class func getBTCAccounts() -> [CHBTCAcount] {
        let realm = RealmDBHelper.acountDB  //Realm数据库
        let datas: Results<CHBTCAcount> = realm.objects(CHBTCAcount.self).sorted(byProperty: "index", ascending: true)
        return datas.toArray()
    }
    
    
    /// 获取最大账号
    ///
    /// - Returns:
    class func getSeqNextValue() -> Int {
        let realm = RealmDBHelper.acountDB  //Realm数据库
        let datas: Results<CHBTCAcount> = realm.objects(CHBTCAcount.self)
        if let seq: Int = datas.max(ofProperty: "index") {
            return seq + 1
        } else {
            return 0
        }
    }
}


// MARK: - 扩展支持比特币功能
extension CHBTCAcount {
    
    /// 账户类型：1.普通HD（单签），2.多重签名
    var accountType: CHAccountType {
        if self.redeemScript == nil {
            return CHAccountType.normal
        } else {
            return CHAccountType.multiSig
        }
    }
    
    /// 获取私钥
    var privateKey: BTCKey? {
        return btcKeychain?.key
    }
    
    /// 获取扩展公钥
    var extendedPrivateKey: String {
        let pubkey = self.btcKeychain?.extendedPrivateKey
        return pubkey!
    }
    
    /// 获取扩展公钥
    var extendedPublicKey: String {
        let pubkey = self.btcKeychain?.extendedPublicKey
        return pubkey!;
    }
    
    /// 获取公钥
    var publicKey: BTCKey {
        let pubkey = self.privateKey?.compressedPublicKey
        let key = BTCKey(publicKey: pubkey as Data!)
        return key!;
    }
    
    /// 获取多重签名的赎回脚本
    var redeemScript: BTCScript? {
        if self.redeemScriptHex == "" {
            return nil
        }
        let script = BTCScript(hex: self.redeemScriptHex)
        return script
    }
    
    //比特币地址
    var address: BTCAddress {
        if self.accountType == .normal {
            return self.publicKey.address   //普通地址
        } else {
            return self.redeemScript!.scriptHashAddress     //多重签名地址
        }
        
    }
    

    /// 初始化
//    convenience init(index: Int, exprvKey: BTCKeychain) {
//        self.init()
//        self.index = index
//        self.btcKeychain = exprvKey
//    }
}
