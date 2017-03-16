//
//  TabBarViewController.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/16.
//  Copyright © 2015年 Chance. All rights reserved.
//

import UIKit
import RealmSwift
import ESTabBarController_swift

class TabBarViewController: ESTabBarController {
    
    var myMetadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CHWalletWrapper.checkWalletRoot() {
            
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
    
    
    //MARK: ios7状态栏修改
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
}


// MARK: - 控制器方法
extension TabBarViewController {
    
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
    
    /**
     弹出TabBar中间钱包多功能按钮
     */
    func showMultiFunctionMenu() {
        let actionSheet = UIAlertController(title: "You can".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Send Bitcoin".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.gotoBTCSendView()
        }))
        
        //多重签名账户可以粘贴别人的签名交易
        actionSheet.addAction(UIAlertAction(title: "Sign Contract".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            
//            self.gotoMultiSigTest()
            self.gotoMultiSigFormTest()
            /*
            let pasteboard = UIPasteboard.general
            if pasteboard.string?.length ?? 0 > 0 {
                self.gotoMultiSigTransactionView(pasteboard.string!)
            } else {
                SVProgressHUD.showInfo(withStatus: "Clipboard is empty".localized())
            }
            */
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    /**
     进入多重签名交易表单界面，进行签名
     */
    func gotoMultiSigTransactionView(_ message: String) {
        
        //初始表单
        do {
            let mtx = try MultiSigTransaction(json: message)
            
            guard let vc = StoryBoard.wallet.initView(type: BTCMultiSigTransactionViewController.self) else {
                return
            }
            
            guard let currentAccount = CHBTCWallet.sharedInstance.getSelectedAccount() else {
                return
            }
            
            vc.currentAccount = currentAccount
            vc.multiSigTx = mtx
            vc.hidesBottomBarWhenPushed = true
            let navc = self.selectedViewController as? UINavigationController
            navc?.pushViewController(vc, animated: true)
            
        } catch {
            SVProgressHUD.showError(withStatus: "Transaction decode error".localized())
        }
        
    }
    
    
    /**
     进入发送比特币界面
     */
    func gotoBTCSendView() {
        
        guard let vc = StoryBoard.wallet.initView(type: BTCSendViewController.self) else {
            return
        }
        
        guard let currentAccount = CHBTCWallet.sharedInstance.getSelectedAccount() else {
            return
        }
        
        vc.btcAccount = currentAccount
        vc.hidesBottomBarWhenPushed = true
        let navc = self.selectedViewController as? UINavigationController
        navc?.pushViewController(vc, animated: true)

    }
    
    //测试待签名列表界面
    func gotoMultiSigTest() {
        
        guard let vc = StoryBoard.wallet.initView(type: BTCSendMultiSigViewController.self) else {
            SVProgressHUD.showError(withStatus: "Unknown error".localized())
            return
        }
        
        guard let currentAccount = CHBTCWallet.sharedInstance.getSelectedAccount() else {
            return
        }
        
        //初始表单
        do {
            //封装一个多重签名交易表单
            let mtx = try MultiSigTransaction(json: "multisig:{\"rawTx\":\"0100000002a2f734139f40d3e01a0259a4423931c47f84b8131f7ceab8f8f71ebe6487c0420000000000ffffffff7cfc40806d63d61714729d3d484a274a757513df3f1e47f8bac979d609e735680100000000ffffffff0200c2eb0b000000001976a914d1d63de21e37c2845b9c134edd02a74881a53d1e88acc0f18e000000000017a9149d9bc7879b31d0244c3f4f117132885d8999ec8f8700000000\",\"redeemScriptHex\":\"522102e7fdca57c00393389e91bb6cb410b4c3dc2861182ca070d6c5df7516eed653aa2103bc05d074eb611cff88ab282d619c54be5d6b9d7d491508ac4e917f82cb29b05752ae\",\"keySignatures\":{}}")
            
            vc.currentAccount = currentAccount
            vc.multiSigTx = mtx
            vc.hidesBottomBarWhenPushed = true
            let navc = self.selectedViewController as? UINavigationController
            navc?.pushViewController(vc, animated: true)
        } catch {
            SVProgressHUD.showError(withStatus: "Transaction decode error".localized())
        }
    }
    
    //测试粘贴签名
    func gotoMultiSigFormTest() {
        
        guard let vc = StoryBoard.wallet.initView(type: BTCMultiSigTxFormViewController.self) else {
            SVProgressHUD.showError(withStatus: "Unknown error".localized())
            return
        }
        
        guard let currentAccount = CHBTCWallet.sharedInstance.getSelectedAccount() else {
            return
        }
        
        vc.currentAccount = currentAccount
        vc.hidesBottomBarWhenPushed = true
        let navc = self.selectedViewController as? UINavigationController
        navc?.pushViewController(vc, animated: true)
        
    }
}


// MARK: - 工厂方法
extension TabBarViewController {
    
    
    /// 默认的钱包Tabbar控制器
    static let walletTab: TabBarViewController = {
        let tabBarController = TabBarViewController()
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background")
        
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 1 {
                return true
            }
            return false
        }
        
        tabBarController.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tabBarController?.showMultiFunctionMenu()
            }
        }
        
        let wallet = StoryBoard.wallet.initView(name: "WalletRootViewController")!
        let setting = StoryBoard.setting.initView(name: "SettingRootViewController")!
        let center = UIViewController()
        
        wallet.tabBarItem = ESTabBarItem(
            TBBouncesContentView(),
            title: "Wallet",
            image: UIImage(named: "tab_wallet_normal"),
            selectedImage: UIImage(named: "tab_wallet_selected"))
        
        center.tabBarItem = ESTabBarItem(
            TBIrregularityContentView(),
            title: nil,
            image: UIImage(named: "tab_btc_big"),
            selectedImage: UIImage(named: "tab_btc_big"))
        
        setting.tabBarItem = ESTabBarItem(
            TBBouncesContentView(),
            title: "Setting",
            image: UIImage(named: "tab_setting_normal"),
            selectedImage: UIImage(named: "tab_setting_normal"))
        
        tabBarController.viewControllers = [wallet, center, setting]
        
        return tabBarController
    }()
}
