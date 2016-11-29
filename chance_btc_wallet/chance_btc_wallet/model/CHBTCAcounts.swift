//
//  BBAcounts.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/4/15.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import KeychainSwift

class CHBTCAcounts: NSObject {
    
    
    //MARK: - 成员变量
    var keychain: KeychainSwift = CHWalletWrapper.keychain       //keychain工具
    
    var index: Int = 0          //账户所在钱包的索引位
    
    /// 获取普通账户名称
    var userNickname: String {
        get {
            let value = self.keychain.get(CHWalletsKeys.UserNickname+"_\(index)")
            return value ?? "";
        }
        
        set {
            self.keychain.set(newValue, forKey: CHWalletsKeys.UserNickname+"_\(index)")
        }
    }
    
    /// 账户类型：1.普通HD（单签），2.多重签名
    var accountType: CHAccountType {
        if self.redeemScript == nil {
            return CHAccountType.Normal
        } else {
            return CHAccountType.MultiSig
        }
    }
    
    /// 获取可扩展的私钥
    var extendedPrivateKey: BTCKeychain?
    
    
    /// 获取私钥
    var privateKey: BTCKey? {
        return extendedPrivateKey?.key
    }
    
    /// 获取扩展公钥
    var extendedPublicKey: String {
        let pubkey = self.extendedPrivateKey?.extendedPublicKey
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
        set {
            let newRedeemScript = newValue!.hex
            self.keychain.set(newRedeemScript!, forKey: CHWalletsKeys.BTCRedeemScript+"_\(index)")
            
            
        }
        get {
            let redeemScript = self.keychain.get(CHWalletsKeys.BTCRedeemScript+"_\(index)")
            if redeemScript == nil || redeemScript == "" {
                return nil
            }
            let script = BTCScript(hex: redeemScript)
            return script;
        }
    }
    
    //比特币地址
    var address: BTCAddress {
        if self.accountType == .Normal {
            return self.publicKey.address   //普通地址
        } else {
            return self.redeemScript!.scriptHashAddress     //多重签名地址
        }
        
    }
    
    
    
    /// 初始化
    convenience init(index: Int, exprvKey: BTCKeychain) {
        self.init()
        self.index = index
        self.extendedPrivateKey = exprvKey
    }
}
