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


/*
 比特币钱包账户，这是一个可以持久化的模型，它保存在数据库中，目标只有realm数据库支持
 1.我们使用的比特币钱包账户模型为HDM——分层确定性钱包
 2.为了记录子账户的在体系中的路径也记录HDM路径，如 "m/44'/0'/2'" (BIP44 bitcoin account #2)
 3.为了实现可以保存多重签名账户，在账户创建同时，记录其赎回脚本redeemScript的hex串
 4.多重签名账户的创建，其实是创建了一个普通单签账户，再使用其公钥生成多重签名的赎回脚本
 5.无论是普通单签账户或多重签名账户，我们都已它的普通账户比特币地址作为唯一id
 6.为了方便用户记忆账户，我们提供昵称命名账户
 */
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
    
    var qrCode: UIImage?                    //二维码缓存图
    var userBalance: UserBalance?           //余额缓存
    
    override static func primaryKey() -> String? {
        return "accountId"
    }

    
    /// 忽略建立的字段
    ///
    /// - Returns:
    override static func ignoredProperties() -> [String] {
        return [
            "btcKeychain",
            "qrCode",
            "userBalance"
        ]
    }
    
    /// 根据HDM钱包索引获取用户
    ///
    /// - Parameter index: 索引位
    /// - Returns: 
    class func getBTCAccount(by index: Int) -> CHBTCAcount? {
        let realm = RealmDBHelper.shared.acountDB  //Realm数据库
        let datas: Results<CHBTCAcount> = realm.objects(CHBTCAcount.self).filter(" index = \(index)").sorted(byProperty: "index", ascending: true)
        return datas.first
    }
    
    /// 获取全部比特币账户
    ///
    /// - Returns:
    class func getBTCAccounts() -> [CHBTCAcount] {
        let realm = RealmDBHelper.shared.acountDB  //Realm数据库
        let datas: Results<CHBTCAcount> = realm.objects(CHBTCAcount.self).sorted(byProperty: "index", ascending: true)
        return datas.toArray()
    }
    
    
    /// 获取最大账号
    ///
    /// - Returns:
    class func getSeqNextValue() -> Int {
        let realm = RealmDBHelper.shared.acountDB  //Realm数据库
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
    
    
    ///
    /// 获取账户公钥在多重签名赎回脚本中的位置
    ///
    /// - Parameter redeemScript: 赎回脚本
    /// - Returns: 所在钥匙串的位置，<0代表找不到
    func index(of redeemScript: BTCScript) -> Int {
        //获取赎回脚本公钥的顺序列表
        let pubkeys = redeemScript.getMultisigPublicKeys()
        
        let index = pubkeys!.1.index(of: self.accountId)
        
        return index ?? -1
    }
    

    /// 初始化
//    convenience init(index: Int, exprvKey: BTCKeychain) {
//        self.init()
//        self.index = index
//        self.btcKeychain = exprvKey
//    }
}
