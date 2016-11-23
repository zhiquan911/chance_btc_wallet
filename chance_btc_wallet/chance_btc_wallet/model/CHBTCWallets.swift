//
//  BBWallets.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/4/15.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import KeychainSwift

class CHBTCWallets: NSObject {
    
    /// MARK: - 成员变量
    fileprivate var keychain: KeychainSwift = CHWalletWrapper.keychain       //keychain工具
    
    //恢复短语
    var passphrase: String {
        get {
            let value = self.keychain.get(CHWalletsKeys.BTCSecretPhrase)
            return value ?? "";
        }
        
        set {
            self.keychain.set(newValue, forKey: CHWalletsKeys.BTCSecretPhrase)
        }
    }
    
    //密码
    var password: String {
        get {
            let value = self.keychain.get(CHWalletsKeys.BTCWalletPassword)
            return value ?? "";
        }
        
        set {
            self.keychain.set(newValue, forKey: CHWalletsKeys.BTCWalletPassword)
        }
    }
    
    //种子
    var seed: Data? {
        get {
            let value = self.keychain.getData(CHWalletsKeys.BTCWalletSeed)
            return value;
        }
        
        set {
            self.keychain.set(newValue!, forKey: CHWalletsKeys.BTCWalletSeed)
        }
    }
    
    //已有账户个数
    var accountsCount: Int {
        get {
            let value = self.keychain.get(CHWalletsKeys.BTCWalletAccountsCount) ?? "0"
            return Int(value)!;
        }
        
        set {
            self.keychain.set(String(newValue), forKey: CHWalletsKeys.BTCWalletAccountsCount)
        }
    }
    
    //钱包的根钥匙串，不是整个模型的根
    var rootKeys: BTCKeychain {
        return self.getBIP44KeyChain()
    }
    

    /// MARK: - 类方法

    //全局唯一实例
    static var sharedInstance: CHBTCWallets = {
        let instance = CHBTCWallets()
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
    
    /**
     创建钱包账户
     
     - parameter password:用户密码
     
     - returns:
     */
    class func createWallet(_ phrase: String? = nil, password: String)
        -> CHBTCWallets? {
            let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(phrase, password: password)
            let wallet: CHBTCWallets
            if mnemonic != nil {
                wallet = CHBTCWallets()
                wallet.passphrase = CHWalletWrapper.getPassphraseByMnemonic(mnemonic!)
                wallet.password = password
                wallet.seed = mnemonic!.seed
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
    class func setDefaultWallet(_ phrase: String, password: String) -> Bool {
        let wallet = CHBTCWallets.createWallet(phrase, password: password)
        if wallet != nil {
            CHBTCWallets.sharedInstance = wallet!
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
     
     - parameter name: 昵称
     - parameter type: 类型
     
     - returns:
     */
    func createHDAccount(_ name: String) -> CHBTCAcounts? {
        //读取钱包钥匙串中第0位作为钱包普通账户
        let accoutsCount = CHBTCWallets.sharedInstance.accountsCount
        let childKeys = CHBTCWallets.sharedInstance.rootKeys.derivedKeychain(at: UInt32(accoutsCount), hardened: true)
        if childKeys != nil {
            let account = CHBTCAcounts()
            account.extendedPrivateKey = childKeys!      //私钥
            account.userNickname = name
            //增加钱包账户数
            CHBTCWallets.sharedInstance.accountsCount = (accoutsCount + 1)
            return  account
        } else {
            return nil
        }
        
    }
    
    /**
     获取HD账户，目前钱包默认一个
     
     - parameter index: 家族中第几个
     
     - returns:
     */
    func getAccount(_ index: Int = 0) -> CHBTCAcounts? {
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(index),
                                                             hardened: true)
        if childKeys != nil {
            let account = CHBTCAcounts(index: index, exprvKey: childKeys!)
            return  account
        } else {
            return nil
        }
        
        
    }
    
    /**
     创建多重签名账户
     
     - parameter name:    账户昵称
     - parameter pubkeys: 公钥base58字符串数组
     
     - returns:
     */
    func createMSAccount(_ name: String, pubkeys:[String]) -> CHBTCAcounts {
        let account = CHBTCAcounts()
        //1.把所有公钥base58转为data
        
        //2.创建多重签名赎回脚本
        
        //3.根据赎回脚本生成新地址
        return account
    }
    
    /**
     获取钱包全部账户列表
     
     - returns: HD账户+多重签名账户
     */
    func getAccounts() -> [CHBTCAcounts] {
        var accounts = [CHBTCAcounts]()
        if self.accountsCount > 0 {
            for i in 0...self.accountsCount - 1 {
                if let account = self.getAccount(i) {
                    accounts.append(account)
                }
            }
        }
        
        return accounts
    }
}