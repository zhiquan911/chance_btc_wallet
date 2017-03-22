//
//  RestoreWalletViewController.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/29.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit


/// 恢复钱包操作
///
/// - initiativeRestore: 主动恢复（用户主动做恢复）
/// - passiveRestore: 被动恢复（钱包首次启动，可以被动恢复）
/// - lookupPassphrase: 查看秘密短语
enum RestoreOperateType {
    case initiativeRestore
    case passiveRestore
    case lookupPassphrase
}

class RestoreWalletViewController: BaseViewController {
    
    @IBOutlet var textViewRestore: CHTextView!
    
    @IBOutlet var buttonConfirm: CHButton!
    @IBOutlet var labelTips: UILabel!
    @IBOutlet var viewStep: UIView!
    
    @IBOutlet var viewStepHeightConstraint: NSLayoutConstraint!
    
    //var isRestore = false
    var restoreOperateType: RestoreOperateType = .initiativeRestore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //首先验证警告一下用户这是一个非常危险的操作，会完全破坏整个HDM钱包的用户信息。
        //TODO:
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - 控制器方法
extension RestoreWalletViewController {
    
    
    /// 配置UI
    func setupUI() {
        //默认不可用
        self.buttonConfirm.isEnabled = false
        //self.labelTips.text = "Passphases：".localized()
        self.buttonConfirm.setTitle("Restore".localized(), for: .normal)
        self.textViewRestore.placeHolder = "Input passphrases to restore wallet".localized()
        
        //是否操作恢复钱包
        switch self.restoreOperateType {
        case .initiativeRestore:
            self.buttonConfirm.isHidden = false
            self.labelTips.text = "Warning：Your current wallet will be removed if your confirm to restore that you inputed".localized()
            self.textViewRestore.isEditable = true
            self.viewStep.isHidden = true
            self.viewStepHeightConstraint.constant = 20
        case .passiveRestore:
            self.buttonConfirm.isHidden = false
            self.labelTips.text = "Only the correct passphrase and password can restore your expected wallet.Even if one character is different, it will be different wallet.(Note: Spaces between words)".localized()
            self.textViewRestore.isEditable = true
            self.viewStep.isHidden = false
            self.viewStepHeightConstraint.constant = 80
        default:
            self.buttonConfirm.isHidden = true
            //请写下密语，并安全保管好，不要随便给别人，以后钱包程序丢失，可通过密语恢复
            self.labelTips.text = "Please mark down this passphrase and safe keeping. Don't give them to anybody. You can restore wallet by this passphrase when you lose you wallet.".localized()
            
            self.textViewRestore.isEditable = false
            self.viewStep.isHidden = true
            self.viewStepHeightConstraint.constant = 20
            //显示恢复密语
            self.textViewRestore.text = CHBTCWallet.sharedInstance.passphrase
        }
    }
    
    
    /// 点击恢复钱包
    ///
    /// - Parameter sender:
    @IBAction func handleRestorePress(_ sender: CHButton) {
        
        AppDelegate.sharedInstance().closeKeyBoard()
        
        if !self.checkValue() {
            return
        }
        
        sender.isEnabled = false
        //1.输入恢复密码，可为空
        self.showPasswordTextAlert { (password) in
            
            //2.根据导入的密语获取HD钱包
            
            let phrase = self.textViewRestore.text!.trim()
            
            //3.恢复钱包
            SVProgressHUD.show(with: SVProgressHUDMaskType.black)
            CHWalletWrapper.create(phrase: phrase, password: password, complete: {
                (success, mnemonic) in
                if !success {   //创建失败
                    SVProgressHUD.showError(withStatus: "Restore wallet failed".localized())
                    sender.isEnabled = true
                    return
                }
                
                //目前只有比特币钱包，恢复一个默认的比特币钱包
                self.restoreBTCWallet(mnemonic: mnemonic!)
            })
            
        }
        
    }
    
    /// 检查输入值是否合法
    ///
    /// - Returns:
    func checkValue() -> Bool {
        if self.textViewRestore.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Passphrase is empty".localized())
            
            return false
        }
        
        return true
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
                    
                    self.leave()
                    return
                } else {    //恢复账户失败
                    //4.默认新建一个HDM普通账户
                    let account = wallet.createHDAccount(by: "Account 1")
                    
                    if account == nil {
                        CHBTCWallet.sharedInstance.selectedAccountIndex = -1
                        SVProgressHUD.showError(withStatus: "Create wallet account failed".localized())
                        self.buttonConfirm.isEnabled = true
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
                        self.leave()
                    })
                }
                
        })
        
    }
    
    
    /// 弹出恢复密码输入框
    ///
    /// - Parameter complete: 回调
    func showPasswordTextAlert(complete: @escaping (_ password: String) -> Void) {
        //弹出密码输入框
        let alertController = UIAlertController(title: "The passphrase's password".localized(),
                                                message: "Input the password if the passphrase has".localized(),
                                                preferredStyle: .alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Input passphrase's password".localized()
            textField.isSecureTextEntry = true
        }
        
        let settingsAction = UIAlertAction(title: "Restore".localized(), style: .default) { (alertAction) in
            let password = alertController.textFields![0]
            complete(password.text!.trim())
            
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
    
    
    /// 离开当前界面
    func leave() {
        
        //初始View默认为系统记录的账户卡片
        WalletViewController.selectedCardIndex = CHBTCWallet.sharedInstance.selectedAccountIndex
        WalletViewController.scrollCardAnimated = false
        
        switch self.restoreOperateType {
        case .passiveRestore:
            SVProgressHUD.dismiss()
            //进入成功界面
            guard let vc = StoryBoard.welcome.initView(type: WelcomeSuccessViewController.self) else {
                return
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            
            SVProgressHUD.showSuccess(withStatus: "The wallet & accounts have been restore successfully".localized())
            
            _ = self.navigationController?.popViewController(animated: true)
        }

        
    }
    
}


// MARK: - 实现TextView委托方法
extension RestoreWalletViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.buttonConfirm.isEnabled = !textView.text.isEmpty
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
