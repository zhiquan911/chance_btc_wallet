//
//  TabBarViewController.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/16.
//  Copyright © 2015年 Chance. All rights reserved.
//

import UIKit
import RealmSwift

class TabBarViewController: UITabBarController {
    
    var myMetadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CHWalletWrapper.checkWalletRoot() {
            let vc = StoryBoard.welcome.initView(name: "WelcomeNavController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        } else {
            
            if !CHBTCWallet.checkBTCWalletExist() {
                //钱包不存在，需要恢复账户体系
            
                let phrase = CHWalletWrapper.passphrase
                let password = CHWalletWrapper.password
                //恢复钱包
                SVProgressHUD.show(with: SVProgressHUDMaskType.black)
                
                let mnemonic = CHWalletWrapper.generateMnemonicPassphrase(phrase, password: password)
                if mnemonic != nil {
                    
                    //目前只有比特币钱包，恢复一个默认的比特币钱包
                    self.restoreBTCWallet(mnemonic: mnemonic!)
                    
                } else {
                    
                    SVProgressHUD.showError(withStatus: "Restore Bitcoin wallet failed".localized())
                }

                
            }
        }
    }
    
    /**
     配置UI
     */
    func setupUI() {
        
        //自定义tabbar的背景颜色和图标，只能是用代码设置才有效果
        self.tabBar.tintColor = UIColor.white
        
        //自定义tabbarItem的图标
        let tabBarItem1 = self.tabBar.items?[0]
        tabBarItem1?.image = UIImage(named: "menu_ico_asset")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem1?.selectedImage = UIImage(named: "menu_ico_asset_active")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.viewControllers![0].tabBarItem = tabBarItem1
        
        let tabBarItem2 = self.tabBar.items?[1]
        tabBarItem2?.image = UIImage(named: "menu_ico_user")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem2?.selectedImage = UIImage(named: "menu_ico_user_active")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.viewControllers![1].tabBarItem = tabBarItem2
        
        //改变UITabBarItem 字体颜色
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor(hex: 0x505050)],
            for: UIControlState())
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor(hex: 0xE30B17)],
            for: UIControlState.selected)
        
        
    }
    
    /// 恢复比特币钱包
    ///
    /// - Parameter mnemonic: 钱包体系记忆体
    func restoreBTCWallet(mnemonic: BTCMnemonic) {
        
        CHBTCWallet.restoreWallet(
            mnemonic: mnemonic,
            completeHandler: { (wallet, accountsRestore) in
                
                //设置当前的首个用户
                CHBTCWallet.sharedInstance.selectedAccountIndex = 0
                
                if accountsRestore {    //恢复账户成功
                    
                    //马上进行同步iCloud
                    let db = RealmDBHelper.shared.acountDB
                    RealmDBHelper.shared.iCloudSynchronize(db: db)
                    
                    SVProgressHUD.showSuccess(withStatus: "The wallet & accounts have been restore successfully".localized())
                    return
                } else {    //恢复账户失败
                    //4.默认新建一个HDM普通账户
                    let account = wallet.createHDAccount(by: "Account 1")
                    
                    if account == nil {
                        CHBTCWallet.sharedInstance.selectedAccountIndex = -1
                        SVProgressHUD.showError(withStatus: "Create wallet account failed".localized())
                        return
                    }
                    
                    
                    SVProgressHUD.dismiss()
                    //5.让用户重置昵称
                    self.showNicknameTextAlert(complete: { (nickname) in
                        
                        if !nickname.isEmpty {
                            let realm = RealmDBHelper.shared.acountDB
                            try! realm.write {
                                account!.userNickname = nickname
                            }
                        }
                        
                        SVProgressHUD.showSuccess(withStatus: "The wallet have been restore successfully".localized())
                    })
                }
                
        })
        
    }
    
    /// 重置昵称
    ///
    /// - Parameter complete:
    func showNicknameTextAlert(complete: @escaping (_ nickname: String) -> Void) {
        //弹出昵称输入框
        let alertController = UIAlertController(title: "Restore wallet successfully".localized(),
                                                message: "Set a new account name",
                                                preferredStyle: .alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Input account name".localized()
            textField.isSecureTextEntry = false
        }
        
        let settingsAction = UIAlertAction(title: "Save".localized(), style: .default) { (alertAction) in
            let nickname = alertController.textFields![0]
            complete(nickname.text!.trim())
            
        }
        alertController.addAction(settingsAction)
        
        //        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        //        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
}
