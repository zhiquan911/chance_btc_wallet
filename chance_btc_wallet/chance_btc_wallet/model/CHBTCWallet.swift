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
    
    // MARK: - 类方法

    //全局唯一实例
    static var sharedInstance: CHBTCWallet = {
        let instance = CHBTCWallet()
        
        //钱包种子hash存在设置默认数据库
        if let hash = instance.seedHash {
            RealmDBHelper.shared.setDefaultRealmForWallet(wallet: instance)
        }
        
        return instance
    }()
    
    
    /// 创建钱包账户
    ///
    /// - Parameters:
    ///   - phrase: 恢复密语
    ///   - password: 恢复密码
    ///   - isDropTable: 是否删除所有表，默认是
    /// - Returns:
    class func createWallet(_ phrase: String? = nil,
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
                RealmDBHelper.shared.setDefaultRealmForWallet(wallet: wallet)
                
                if isDropTable {
                    //清空数据，重建用户体系
                    let realm = RealmDBHelper.shared.acountDB
                    try! realm.write {
                        realm.deleteAll()
                    }
                }
            } else {
                return nil
            }
            
            return wallet
    }
    
    
    /// 使用密语和密码恢复钱包
    /// 钱包恢复成功后，会尝试恢复账户体系数据，先检查设备是否开启icloud，尝试使用icloud恢复，
    /// icloud恢复失败，就尝试使用本地进行恢复，如果都失败，新的钱包账户数据库是一个空账户数据，
    /// 调用者可以根据accountRestored判断是否账户恢复成功，不成功需要自己建立一条新账户
    /// - Parameters:
    ///   - phrase: 密语
    ///   - password: 密码
    ///   - completeHandler: 执行结果回调
    class func restoreWallet(phrase: String,
                             password: String,
                             completeHandler: @escaping (_ wallet: CHBTCWallet?, _ accountRestored: Bool) -> Void) {
        let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(phrase, password: password)
        let wallet: CHBTCWallet
        var accountRestored = false //账户体系是否恢复成功
        if mnemonic != nil {
            
            /***** 1.清空用户的keychain数据 *****/
            CHWalletWrapper.deleteAllWallets()
            
            /***** 2.密语和密码恢复钱包 *****/
            wallet = CHBTCWallet()
            wallet.password = password
            wallet.passphrase = CHWalletWrapper.getPassphraseByMnemonic(mnemonic!)
            
            /***** 3.检查可支持的恢复方式 *****/
            let backupStatus = wallet.checkAccountsBackupStatus()
            
            /***** 4.如果icloud支持，优先使用icloud恢复 *****/
            if backupStatus.icloudBackup {
                //支持icloud恢复，执行icloud恢复
                wallet.restoreAccountsByICloud(completeHandler: { (restoreSuccess) in
                    
                    /***** 5.如果icloud恢复数据库到本地，就可以设置本地的数据库为默认数据库 *****/
                    accountRestored = wallet.restoreAccountsByLocal()
                    
                    //回调上层过程
                    completeHandler(wallet, accountRestored)
                    return //保证执行完
                })
            } else {
                
                Log.debug("数据库【\(wallet.accountsFileName)】尝试使用本地备份")
                
                /***** 5.使用本地的恢复 *****/
                accountRestored = wallet.restoreAccountsByLocal()
                
                //回调上层过程
                completeHandler(wallet, accountRestored)
                return //保证执行完
            }
            
            
        } else {
            //连创建钱包都失败
            //回调上层过程
            completeHandler(nil, accountRestored)
            return //保证执行完
        }
    }
    
    // MARK: - 内部方法
    
    /**
     采用BIP44的HD模型标准获取钱包账户
     账户的路径在：m/44'/0'/{account}'/
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
    
    
    /// 获取账户数据库文件名
    ///
    /// - Returns: 文件名
    var accountsFileName: String {
        let seedHash = self.seedHash!
        let fileName = "wallet_\(seedHash).realm"
        return fileName
    }
    
    /// 检查钱包的账户数据备份状态
    ///
    /// - Parameter wallet: 钱包
    /// - Returns: localBackup 是否有本地备份，是否开启icloud备份
    func checkAccountsBackupStatus() -> (localBackup: Bool, icloudBackup: Bool) {
        
        var localBackup = false
        var icloudBackup = false
        
        //账户数据库文件名
        let fileName = self.accountsFileName
        
        //iCloud上的备份文件
        if CHDocument.getiCloudDocumentURL() != nil {
            icloudBackup = true
        }
        
        //检查本地恢复文件是否存在
        let fileManager = FileManager.default
        var des = RealmDBHelper.accountDBFilePath
        des.appendPathComponent(fileName)
        Log.debug("des = \(des)")
        
        if fileManager.fileExists(atPath: des.path) {
            localBackup = true
        }

        return (localBackup, icloudBackup)
    }
    
    
    /// icloud恢复账户数据
    ///
    /// - Parameters:
    ///   - wallet: 要恢复的钱包
    ///   - completeHandler: 恢复结果回调
    func restoreAccountsByICloud(completeHandler: @escaping (_ accountRestored: Bool) -> Void) {
        var accountRestored = false         //使用icloud恢复成功？
        
        //账户数据库文件名
        let fileName = self.accountsFileName
        
        //iCloud上的备份文件
        var iCloudPath = CHDocument.getiCloudDocumentURL()! //icloud已经开启，备份路径已经有
        iCloudPath.appendPathComponent(fileName)
        
        //恢复的目标路径
        let fileManager = FileManager.default
        var des = RealmDBHelper.accountDBFilePath
        des.appendPathComponent(fileName)
        
        //检查本地是否有备份文件，记录文件最后修改时间
        var localLastModifyTimeInterval: TimeInterval = 0
        if fileManager.fileExists(atPath: des.path) {
            let attributes = try? fileManager.attributesOfItem(atPath: des.path)
            
            //本地文件的最后修改时间
            let localLastModifyDate = attributes?[FileAttributeKey.modificationDate] as? Date
            localLastModifyTimeInterval = localLastModifyDate!.timeIntervalSinceReferenceDate
        }
        
        /***** 1.检查icloud文件能否打开，打开就说明有备份 *****/
        let doc = CHDocument(fileURL: iCloudPath)
        doc.open { success in
            Log.debug("数据库【\(fileName)】是否有iCloud备份 = \(success)")
            
            if success {
                
                /***** 2.有备份，iCloud与本地的对修改时间 *****/
                
                //iCloud文件的最后修改时间
                let iCloudLastModifyDate = doc.fileModificationDate!
                
                //如果iCloud的文件较前就使用iCloud的数据恢复
                Log.debug("iCloudLastModifyDate = \(iCloudLastModifyDate.timeIntervalSinceReferenceDate)")
                Log.debug("localLastModifyTimeInterval = \(localLastModifyTimeInterval)")
                if iCloudLastModifyDate.timeIntervalSinceReferenceDate >= localLastModifyTimeInterval {

                    /***** 2.iCloud的备份文件最新，使用其恢复 *****/
                    doc.save(to: des, for: UIDocumentSaveOperation.forOverwriting, completionHandler: { (saveSuccess) in
                        //覆盖文件成功
                        if saveSuccess {
                            Log.debug("iCloud账户备份恢复成功")
                            //有iCloud文件可恢复账户数据
                            accountRestored = true
                        } else {
                            Log.debug("iCloud账户备份恢复失败，使用本地数据库恢复")
                            accountRestored = false
                        }
                        
                        //回调上层过程
                        completeHandler(accountRestored)
                    })
                } else {
                    accountRestored = false
                    //回调上层过程
                    completeHandler(accountRestored)
                }
                
                
            } else {
                Log.debug("数据库【\(fileName)】没有iCloud备份")
                
                accountRestored = false
                //回调上层过程
                completeHandler(accountRestored)
            }
            
        }
        
    }
    
    /// 本地文件恢复账户数据
    ///
    /// - Parameters:
    ///   - wallet: 要恢复的钱包
    ///   - return 本地恢复结果
    func restoreAccountsByLocal() -> Bool {
        
        var accountRestored = false         //使用本地恢复成功？
        
        //账户数据库文件名
        let fileName = self.accountsFileName

        //恢复的目标路径
        let fileManager = FileManager.default
        var des = RealmDBHelper.accountDBFilePath
        des.appendPathComponent(fileName)
        
        if fileManager.fileExists(atPath: des.path) {
            //本地存在文件
            accountRestored = true
        }
        
        //直接把默认数据设置钱包的就可以恢复
        RealmDBHelper.shared.setDefaultRealmForWallet(wallet: self)
        
        return accountRestored
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
            account.keyPath = "m/44'/0'/\(account.index)'"
            
            //保存新账户到数据库
            let realm = RealmDBHelper.shared.acountDB
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
        account.accountId = account.publicKey.address.string
        account.keyPath = "m/44'/0'/\(account.index)'"
        
        //5.保存新账户到数据库
        let realm = RealmDBHelper.shared.acountDB
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
