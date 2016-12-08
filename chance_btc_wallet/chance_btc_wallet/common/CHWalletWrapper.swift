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

class CHWalletWrapper: NSObject {
    
    /// MARK: - 回调
    typealias Complete = (_ flag: Bool, _ error: String?) -> Void    //成功的回调
    
    
    /// MARK: - 类变量
    
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
    
    /**
     获取苹果keychain工具实例
     */
    static let keychain: KeychainSwift = {
        let instance = KeychainSwift(keyPrefix: "chance_btc_wallet_")
        return instance
    }()
    
    /// MARK: - 类方法
    
    
    /// 清空所有钱包数据
    class func deleteAllWallets() {
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
    
    /**
     检查钱包是否存在
     
     - returns:
     */
    class func checkBTCWalletExist() -> Bool {
        
        //1.检查钱包种子在不在
        guard let seedHash = CHBTCWallet.sharedInstance.seedHash else {
            return false
        }
        
        //2.检查账户体系数据库文件在不在
        guard RealmDBHelper.checkRealmForWalletExist(seedHash: seedHash) else {
            return false
        }
        
        return true
    }
    
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
