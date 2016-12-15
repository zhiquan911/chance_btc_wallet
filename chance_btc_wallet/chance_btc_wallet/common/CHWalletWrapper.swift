//
//  BBHDWalletWrapper.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/14.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import KeychainSwift
import CloudKit


/* 
 CHWalletWrapper是对整个钱包应用的包装工具类，创建意义:
 1.考虑到一个钱包应用可能包含多种数字货币的存储，所以它可以使用一种通用的记忆方式来创建多种数字货币钱包。
 2.密码，指纹，备份方式等安全功能都不是数字货币的主要属性，这个工具类统一进行配置和管理
 3.提供使用通用的恢复功能，恢复全部数字货币钱包
 4.提供超级ROOT功能，可以重置整个钱包应用，其实就是把最底层的加密钥匙串信息全部清除
 */
class CHWalletWrapper: NSObject {
    
    // MARK: - 最重要的钥匙信息，恢复密语和密码
    
    /**
     获取苹果keychain工具实例
     */
    class var keychain: KeychainSwift {
        return KeychainSwift(keyPrefix: "chance_btc_wallet_")
    }
    
    
    //密码
    class var password: String {
        get {
            let value = CHWalletWrapper.keychain.get(CHWalletsKeys.BTCWalletPassword)
            return value ?? "";
        }
        
        set {
            CHWalletWrapper.keychain.set(newValue, forKey: CHWalletsKeys.BTCWalletPassword,
                              withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }
    }
    
    //恢复密语
    class var passphrase: String {
        get {
            let value = CHWalletWrapper.keychain.get(CHWalletsKeys.BTCSecretPhrase)
            return value ?? ""
        }
        
        set {
            CHWalletWrapper.keychain.set(newValue, forKey: CHWalletsKeys.BTCSecretPhrase,
                              withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }
    }

    
    
    // MARK: - 类变量
    
    /// 设置指纹密码是否开启
    class var enableTouchID: Bool {
        get {
            let value = UserDefaults.standard.bool(forKey: CHWalletsKeys.EnableTouchID);
            return value
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CHWalletsKeys.EnableTouchID);
            UserDefaults.standard.synchronize();
        }
    }
    
    /// 获取默认选择区块链云节点
    class var selectedBlockchainNode: BlockchainNode {
        get {
            let value = UserDefaults.standard.value(forKey: CHWalletsKeys.SelectedBlockchainNode) as? String
            let node = value ?? BlockchainNode.blockchain_info.rawValue
            return BlockchainNode(rawValue: node)!
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CHWalletsKeys.SelectedBlockchainNode)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 是否开启icloud自动同步
    class var enableICloud: Bool {
        get {
            let value = UserDefaults.standard.bool(forKey: CHWalletsKeys.EnableICloud)
            return value
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CHWalletsKeys.EnableICloud)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    
    
    // MARK: - 类方法
    
    
    /// 检查钱包是否有钥匙串
    ///
    /// - Returns:
    class func checkWalletRoot() -> Bool {
        
        if CHWalletWrapper.passphrase.isEmpty {
            return false
        }
        
        if CHWalletWrapper.password.trim().isEmpty {
            return false
        }
        
        return true
    }
    
    /// 清空所有数字货币钱包数据，创新安装应用系统不会自动恢复，需要手动恢复
    class func deleteAllWallets() {
        //删除所有钱包缓存数据库
        
        
        //同时把最底层的钥匙串删除
        CHWalletWrapper.keychain.clear()
        
    }
    
    /**
     用短语和密码生成一个可恢复的钱包
     
     - parameter phrase:   短语
     - parameter password: 密码
     
     - returns: 钱包记忆体
     */
    class func generateMnemonicPassphrase(_ phrase:String? = nil, password: String? = nil) -> BTCMnemonic? {
        let mnemonic: BTCMnemonic?
        if phrase != nil {
            let words = phrase!.components(separatedBy: " ")
            //Log.debug("words = \(words)")
            mnemonic = BTCMnemonic(words: words, password: password, wordListType: .english)
        } else {
            mnemonic = BTCMnemonic(entropy: BTCRandomDataWithLength(16) as Data!, password: password, wordListType: .english)
        }
        return mnemonic
    }
    
    /**
     返回短语字符串
     
     - parameter mnemonic:
     
     - returns:
     */
    class func getPassphraseByMnemonic(_ mnemonic :BTCMnemonic) -> String {
        return (mnemonic.words as NSArray).componentsJoined(by: " ")
    }
    
    /**
     检查短语是否有效
     
     - parameter phrase:
     
     - returns:
     */
    class func phraseIsValid(_ phrase:String, password: String? = nil) -> Bool {
        return BTCMnemonic(words: phrase.components(separatedBy: " "), password: password, wordListType: .english) != nil
    }
    
    
    
    /// 创建或恢复钱包体系
    ///
    /// - Parameters:
    ///   - phrase: 恢复密语
    ///   - password: 密码
    ///   - complete: 回调：是否成功，密语实体
    class func create(phrase: String,
                      password: String,
                      complete:(_ success: Bool, _ mnemonic: BTCMnemonic?) -> Void) {
        var flag = false
        let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(phrase, password: password)
        if mnemonic != nil {    //重建成功
            
            //创建或恢复钱包都要清空以前的keychain
            CHWalletWrapper.keychain.clear()
            
            //记录最新的恢复密语和密码
            CHWalletWrapper.password = password
            CHWalletWrapper.passphrase = CHWalletWrapper.getPassphraseByMnemonic(mnemonic!)
            
            flag = true
        } else {
            flag = false
        }
        //回调给上层过程
        complete(flag, mnemonic)
    }
        
}


// MARK: - 钱包操作解锁
extension CHWalletWrapper {
    
    /// 回调函数
    typealias Complete = (_ flag: Bool, _ error: String?) -> Void    //成功的回调
    
    /**
     钱包操作解锁
     
     - parameter vc:       当前视图
     - parameter complete: 完成回调
     */
    class func unlock(
        vc: UIViewController,
        complete: Complete?) {
        
        let passwordVerify = {
            () -> Void in
            //选择输入密码
            if CHBTCWallet.sharedInstance.password != "" {
                //如果用户设置了密码，弹出密码输入框
                let alertController = UIAlertController(title: "Password validation".localized(),
                                                        message: "",
                                                        preferredStyle: .alert)
                
                alertController.addTextField {
                    (textField: UITextField!) -> Void in
                    textField.placeholder = "Input your password".localized()
                    textField.isSecureTextEntry = true
                }
                
                let settingsAction = UIAlertAction(title: "Validate".localized(), style: .default) { (alertAction) in
                    let password = alertController.textFields![0]
                    //password.text = "123456"    //debug
                    if password.text!.length > 0 {
                        if password.text! == CHBTCWallet.sharedInstance.password {
                            complete?(true, "")
                        } else {
                            Log.debug("correct is: \(CHBTCWallet.sharedInstance.password)")
                            complete?(false, "Password wrong".localized())
                        }
                    } else {
                        complete?(false, "Password is empty".localized())
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                vc.present(alertController, animated: true, completion: nil)
            }
        }
        
        //1.指纹验证解锁
        if CHWalletWrapper.enableTouchID {
            
            TouchIDUtils.authenticateUser(
                "Authentication".localized(),
                fallbackTitle: "Password".localized(),
                userFallback: {
                    passwordVerify()
            }) { (flag, error) in
                
                //指纹验证结构
                complete?(flag, error)
            }
        } else {
            //2.密码验证
            passwordVerify()
        }
        
    }
    
}
