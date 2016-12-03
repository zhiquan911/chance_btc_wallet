//
//  BBWallets.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/15.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import KeychainSwift
import SwiftyJSON
import CryptoSwift
import CloudKit
import RealmSwift

class CHBTCWallet: NSObject {
    
    // MARK: - keychain保存的重要数据：种子+密码
    
    fileprivate var keychain: KeychainSwift = CHWalletWrapper.keychain       //keychain工具
    
    //密码
    var password: String {
        get {
            let value = self.keychain.get(CHWalletsKeys.BTCWalletPassword)
            return value ?? "";
        }
        
        set {
            self.keychain.set(newValue, forKey: CHWalletsKeys.BTCWalletPassword,
                              withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }
    }
    
    //恢复密语
    var passphrase: String {
        get {
            let value = self.keychain.get(CHWalletsKeys.BTCSecretPhrase)
            return value ?? ""
        }
        
        set {
            self.keychain.set(newValue, forKey: CHWalletsKeys.BTCSecretPhrase,
                              withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }
    }
    
    // MARK: - 成员变量
    
    /// 获取默认选的账户
    var selectedAccountIndex: Int {
        get {
            let value = UserDefaults.standard.value(forKey: CHWalletsKeys.SelectedAccount) as? Int
            return value ?? -1
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CHWalletsKeys.SelectedAccount)
            UserDefaults.standard.synchronize();
        }
    }
    
    //种子
    var seed: Data? {
        guard let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(self.passphrase, password: self.password) else {
            return nil
        }
        return mnemonic.seed
    }
    
    //种子hash
    var seedHash: String? {
        guard let seed = self.seed else {
            return nil
        }
        return seed.sha256().toHexString()
    }
    
    //钱包的根钥匙串，不是整个模型的根
    var rootKeys: BTCKeychain {
        return self.getBIP44KeyChain()
    }
    
    /// MARK: - 类方法

    //全局唯一实例
    static var sharedInstance: CHBTCWallet = {
        let instance = CHBTCWallet()
        
        //钱包种子hash存在设置默认数据库
        if let hash = instance.seedHash {
            RealmDBHelper.setDefaultRealmForWallet(seedHash: hash)
        }
        
        return instance
    }()
    
    
    /**
     采用BIP44的HD模型标准获取钱包账户
     
     - returns:
     */
    func getBIP44KeyChain() -> BTCKeychain{
        let masterKey = BTCKeychain(seed: self.seed)
        //遵循BIP44协议的HD模型
        let purposeKeychain = masterKey!.derivedKeychain(at: 44, hardened:true)
        //0为比特币
        let coinTypeKeychain = purposeKeychain?.derivedKeychain(at: 0, hardened:true)
        return coinTypeKeychain!
    }
    
    
    /// 创建钱包账户
    ///
    /// - Parameters:
    ///   - phrase: 恢复密语
    ///   - password: 恢复密码
    ///   - isDropTable: 是否删除所有表，默认是
    /// - Returns:
    func createWallet(_ phrase: String? = nil,
                            password: String,
                            isDropTable: Bool = true)
        -> CHBTCWallet? {
            let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(phrase, password: password)
            let wallet: CHBTCWallet
            if mnemonic != nil {
                //3.清空用户的keychain数据
                CHWalletWrapper.deleteAllWallets()
                
                wallet = CHBTCWallet()
                wallet.password = password
                wallet.passphrase = CHWalletWrapper.getPassphraseByMnemonic(mnemonic!)
                
                //切换钱包的数据库
                let seedHash = wallet.seedHash!
                RealmDBHelper.setDefaultRealmForWallet(seedHash: seedHash)
                
                if isDropTable {
                    //清空数据，重建用户体系
                    let realm = RealmDBHelper.acountDB
                    try! realm.write {
                        realm.deleteAll()
                    }
                }
            } else {
                return nil
            }
            
            return wallet
    }
    
    /**
     设置当前默认钱包
     设置默认钱包后，原有的钱包下的账户会清除，要恢复，必须拿原来的短语和密码回复
     - parameter passphrase: 短语
     - parameter password:   密码
     */
    func setDefaultWallet(_ phrase: String, password: String) -> Bool {
        let wallet = CHBTCWallet.sharedInstance.createWallet(phrase, password: password,isDropTable: false)
        if wallet != nil {
            CHBTCWallet.sharedInstance = wallet!
            return true
        } else {
            return false
        }
        
    }
    
    /**
     删除钱包账户
     
     - parameter passphrase:
     - parameter password:
     */
    func cleanWallet(_ passphrase: String, password: String? = nil) -> Bool {
        return false
    }
    
    
    /**
     创建HD用户
     关键的私钥不保存到数据库，只要有根私钥就可以找到索引对应的账户
     - parameter name: 昵称
     - parameter type: 类型
     
     - returns:
     */
    func createHDAccount(by name: String) -> CHBTCAcount? {
        //读取钱包钥匙串中第N位作为钱包普通账户
        let seqNextValue = CHBTCAcount.getSeqNextValue()    //用户体系的索引序列
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(seqNextValue), hardened: true)
        if childKeys != nil {
            let account = CHBTCAcount()
            account.btcKeychain = childKeys!      //私钥
            
            //记录数据库字段
            account.index = seqNextValue
            account.userNickname = name
            account.accountId = account.address.string
            
            //保存新账户到数据库
            let realm = RealmDBHelper.acountDB
            try! realm.write {
                realm.add(account, update: true)
            }

            return  account
        } else {
            return nil
        }
        
    }
    
    
    /// 是否存在用户数据
    ///
    /// - Returns:
    func existAccounts() -> Bool {
        var flag = false
        if self.getAccounts().count > 0 {
            flag = true
        } else {
            flag = false
        }
        return flag
    }
    
    /**
     获取HD账户，目前钱包默认一个
     
     - parameter index: 家族中第几个
     
     - returns:
     */
    func getAccount(by index: Int = 0) -> CHBTCAcount? {
        let account = CHBTCAcount.getBTCAccount(by: index)
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(index),
                                                             hardened: true)
        account?.btcKeychain = childKeys
        return account
    }
    
    
    /// 创建多重签名账户
    ///
    /// - Parameters:
    ///   - name: 账户名
    ///   - otherPubkeys: 其它公钥
    ///   - required: 最少签名次数
    /// - Returns:
    func createMSAccount(by name: String, otherPubkeys:[String], required: Int) -> CHBTCAcount? {
        
        //1.读取钱包钥匙串中第N位作为钱包普通账户
        let seqNextValue = CHBTCAcount.getSeqNextValue()    //用户体系的索引序列
        guard let childKeys = self.rootKeys.derivedKeychain(at: UInt32(seqNextValue), hardened: true) else {
            return nil
        }
        
        //初始化账户
        let account = CHBTCAcount()
        account.index = seqNextValue
        account.btcKeychain = childKeys      //私钥
    
        //2.把所有扩展公钥转为data
        var pubKeysData = [Data]()
        pubKeysData.append(account.privateKey!.compressedPublicKey as Data)
        
        for extendedKey in otherPubkeys {
            guard let otherPubkey = BTCKeychain(extendedKey: extendedKey) else {
                return nil
            }
            pubKeysData.append(otherPubkey.key.compressedPublicKey as Data)
        }
        
        //3.创建多重签名赎回脚本
        guard let script = BTCScript(publicKeys: pubKeysData, signaturesRequired: UInt(required)) else {
            return nil
        }
        
        //4.记录数据库字段
        account.userNickname = name
        account.redeemScriptHex = script.hex
        account.accountId = account.address.string
        
        //5.保存新账户到数据库
        let realm = RealmDBHelper.acountDB
        try! realm.write {
            realm.add(account, update: true)
        }
        
        return account
    }
    
    /**
     获取钱包全部账户列表
     
     - returns: HD账户+多重签名账户
     */
    func getAccounts() -> [CHBTCAcount] {
        let accounts = CHBTCAcount.getBTCAccounts()
        for account in accounts {
            let childKeys = self.rootKeys.derivedKeychain(at: UInt32(account.index),
                                                          hardened: true)
            account.btcKeychain = childKeys
            
        }
        return accounts
    }
}
