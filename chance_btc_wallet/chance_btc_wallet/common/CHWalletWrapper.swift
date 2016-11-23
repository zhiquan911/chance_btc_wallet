//
//  BBHDWalletWrapper.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/4/14.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import KeychainSwift

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
    
    /// 获取默认选的账户
    class var selectedAccount: String? {
        get {
            let value = UserDefaults.standard.value(forKey: CHWalletsKeys.SelectedAccount) as? String
            return value;
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CHWalletsKeys.SelectedAccount)
            UserDefaults.standard.synchronize();
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
    
    /**
     用短语和密码生成一个可恢复的钱包
     
     - parameter phrase:   短语
     - parameter password: 密码
     
     - returns: 钱包记忆体
     */
    class func generateMnemonicPassphrase(_ phrase:String? = nil, password: String? = nil) -> BTCMnemonic? {
        let mnemonic: BTCMnemonic
        if phrase != nil {
            mnemonic = BTCMnemonic(words: phrase!.components(separatedBy: " "), password: password, wordListType: .english)
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
        let seed = CHBTCWallets.sharedInstance.seed
        if seed == nil {
            return false
        } else {
            return true
        }
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
            if CHBTCWallets.sharedInstance.password != "" {
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
                    if password.text!.length > 0 {
                        if password.text! == CHBTCWallets.sharedInstance.password {
                            complete?(true, "")
                        } else {
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
