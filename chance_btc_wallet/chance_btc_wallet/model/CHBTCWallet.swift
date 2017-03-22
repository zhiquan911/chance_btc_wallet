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

/*
 比特币钱包核心模型，整个应用只提供一个全局单例的比特币钱包，而一个比特币钱包提供多个账户来管理资金
 提供以下功能：
 1.提供创建一个默认使用的比特币钱包单例
 2.提供使用统一的恢复方式，恢复一个比特币钱包功能
 3.提供创建HDM账户和Multi-Sig账户功能
 4.提供备份账户体系功能
 5.提供重置为空钱包功能
 */
class CHBTCWallet: NSObject {
    
    /// 获取比特币交易数据库文件名
    ///
    /// - Returns: 文件名
    static var transactionFileName: String {
        let fileName = "btc_wallet_tx"
        return fileName
    }
    
    //btc交易记录数据库路径
    static var transactionDBFilePath: URL {
        let fileManager = FileManager.default
        let directoryURL = RealmDBHelper.databaseFilePath
            .appendingPathComponent("btc_tx")
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try! fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
    
    //密码
    var password: String {
        return CHWalletWrapper.password
    }
    
    //恢复密语
    var passphrase: String {
        return CHWalletWrapper.passphrase
    }
    
    
    
    /// 获取账户数据库文件名
    ///
    /// - Returns: 文件名
    var accountsFileName: String {
        let seedHash = self.seedHash!
        let fileName = "btc_wallet_\(seedHash).realm"
        return fileName
    }
    
    
    //btc账户数据库路径
    var accountDBFilePath: URL {
        let fileManager = FileManager.default
        let directoryURL = RealmDBHelper.databaseFilePath
            .appendingPathComponent("btc_accounts")
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try! fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
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
        //采用BTC的双hash处理种子
        let hash = BTCHash160(seed).hex()
        return hash
    }
    
    //钱包的根钥匙串，不是整个模型的根
    var rootKeys: BTCKeychain {
        return self.getBIP44KeyChain()
    }

    /// 用于记录钱包是否存在数据，第一次执行checkBTCWalletExist后如果存在就赋值true。
    var isBTCWalletExist = false
    
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
    ///   - mnemonic: 钱包系统记忆体
    ///   - isDropTable: 是否删除所有表，默认是
    /// - Returns:
    class func createWallet(mnemonic: BTCMnemonic) -> CHBTCWallet {
        
        //新建比特币钱包
        let wallet = CHBTCWallet()
        
        //建立钱包的数据库
        RealmDBHelper.shared.setDefaultRealmForWallet(wallet: wallet)
        
        //清空数据，重建用户体系
        let realm = RealmDBHelper.shared.acountDB
        try! realm.write {
            realm.deleteAll()
        }
        
        return wallet
    }
    
    
    /// 使用密语和密码恢复钱包
    /// 钱包恢复成功后，会尝试恢复账户体系数据，先检查设备是否开启icloud，尝试使用icloud恢复，
    /// icloud恢复失败，就尝试使用本地进行恢复，如果都失败，新的钱包账户数据库是一个空账户数据，
    /// 调用者可以根据accountRestored判断是否账户恢复成功，不成功需要自己建立一条新账户
    /// - Parameters:
    ///   - mnemonic: 钱包系统记忆体
    ///   - password: 密码
    ///   - completeHandler: 执行结果回调
    class func restoreWallet(mnemonic: BTCMnemonic,
                             completeHandler: @escaping (_ wallet: CHBTCWallet, _ accountRestored: Bool) -> Void) {
        
        var accountRestored = false //账户体系是否恢复成功
        
        /***** 2.密语和密码创建钱包 *****/
        let wallet = CHBTCWallet()
        
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
    }
    
    
    /**
     检查比特币钱包是否存在
     
     - returns:
     */
    class func checkBTCWalletExist() -> Bool {
        let wallet = CHBTCWallet.sharedInstance
        
        //如果缓存值为false才检查数据库文件
        guard wallet.isBTCWalletExist == false else {
            return wallet.isBTCWalletExist
        }
        
        //1.检查钱包种子在不在
        guard wallet.seedHash != nil else {
            wallet.isBTCWalletExist = false
            return wallet.isBTCWalletExist
        }
        
        //2.检查账户体系数据库文件在不在
        guard RealmDBHelper.shared.checkRealmForWalletExist(wallet: wallet) else {
            wallet.isBTCWalletExist = false
            return wallet.isBTCWalletExist
        }
        
        //3.检查账户是否存在
        guard wallet.getAccounts().count > 0 else {
            wallet.isBTCWalletExist = false
            return wallet.isBTCWalletExist
        }
        wallet.isBTCWalletExist = true
        return wallet.isBTCWalletExist
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
        var des = self.accountDBFilePath
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
        var des = self.accountDBFilePath
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
//                if iCloudLastModifyDate.timeIntervalSinceReferenceDate >= localLastModifyTimeInterval {
                    /***** 2.优先采用iCloud的备份，使用其恢复 *****/
                    
                    //bug:UIDocument在打开过程中保存新数据到其它目录，会导致原来的icloud路径的文件丢失，我暂未找到解决方法，目前临时解决是，恢复完成文件后，再上传一次到icloud上。如果上传失败，下次就无法再使用icloud备份恢复了，因为icloud的文件已经丢失了。
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
//                } else {
//                    accountRestored = false
//                    //回调上层过程
//                    completeHandler(accountRestored)
//                }
                
                
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
        var des = self.accountDBFilePath
        des.appendPathComponent(fileName)
        
        if fileManager.fileExists(atPath: des.path) {
            //本地存在文件
            accountRestored = true
        }
        
        //直接把默认数据设置钱包的就可以恢复
        RealmDBHelper.shared.setDefaultRealmForWallet(wallet: self)
        
        //检查用户数据是否存在至少1条
        if self.getAccounts().count > 0 {
            accountRestored = true
        } else {
            accountRestored = false
        }
        
        return accountRestored
    }
    
    
    /**
     删除钱包账户
     */
    func cleanWallet() -> Bool {
        let flag = false
        
        return flag
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
    func getAccount(byIndex index: Int = 0) -> CHBTCAcount? {
        let account = CHBTCAcount.getBTCAccount(byIndex: index)
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(index),
                                                      hardened: true)
        account?.btcKeychain = childKeys
        return account
    }
    
    /**
     获取HD账户，目前钱包默认一个
     
     - parameter index: 家族中第几个
     
     - returns:
     */
    func getAccount(byID accountId: String) -> CHBTCAcount? {
        guard let account = CHBTCAcount.getBTCAccount(byID: accountId) else {
            return nil
        }
        
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(account.index),
                                                      hardened: true)
        account.btcKeychain = childKeys
        return account
    }
    
    /**
     获取HD账户，目前钱包默认一个
     
     - parameter index: 家族中第几个
     
     - returns:
     */
    func getSelectedAccount() -> CHBTCAcount? {
        guard self.selectedAccountIndex >= 0 else {
            return nil
        }
        
        let account = CHBTCAcount.getBTCAccount(byIndex: self.selectedAccountIndex)
        let childKeys = self.rootKeys.derivedKeychain(at: UInt32(self.selectedAccountIndex),
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
