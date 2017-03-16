//
//  WelcomeCreateAccountViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/18.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import RealmSwift

class WelcomeCreateAccountViewController: BaseViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var buttonConfirm: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelTextNickname: CHLabelTextField!
    @IBOutlet var labelTextPassword: CHLabelTextField!
    @IBOutlet var labelTextConfirm: CHLabelTextField!
    
    var phrase = ""             //密语
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 控制器方法
extension WelcomeCreateAccountViewController {
    
    
    /// 配置UI
    func setupUI() {
        
        self.navigationItem.title = "Wallet Account".localized()
        
        self.labelTitle.text = "Create Account".localized()
        
        self.labelTextNickname.title = "First Account Nickname".localized()
        self.labelTextNickname.placeholder = "Give your account a nickname".localized()
        self.labelTextNickname.textField?.keyboardType = .default
        self.labelTextNickname.delegate = self
        
        self.labelTextPassword.title = "Wallet Passworde".localized()
        self.labelTextPassword.placeholder = "More complex the more secure".localized()
        self.labelTextPassword.textField?.isSecureTextEntry = true
        self.labelTextPassword.delegate = self
        
        self.labelTextConfirm.title = "Validate Password".localized()
        self.labelTextConfirm.placeholder = "Input the wallet password again".localized()
        self.labelTextConfirm.textField?.isSecureTextEntry = true
        self.labelTextConfirm.textField?.returnKeyType = .done
        self.labelTextConfirm.delegate = self
        
        self.buttonConfirm.setTitle("Create".localized(), for: [.normal])
        
    }
    
    //检测输入值是否合法
    func checkValue() -> Bool {
        if self.labelTextNickname.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Nickname is empty".localized())
            
            return false
        }
        
        if self.labelTextPassword.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Password is empty".localized())
            return false
        }
        
        if self.labelTextConfirm.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Confirm password is empty".localized())
            return false
        }
        if self.labelTextConfirm.text != self.labelTextPassword.text {
            SVProgressHUD.showInfo(withStatus: "Two Passwords is different".localized())
            return false
        }
        
        return true
    }
    
    
    
    /**
     点击确认按钮
     
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
        if self.checkValue() {
            let password = self.labelTextPassword.text.trim()
            //创建钱包系统
            CHWalletWrapper.create(phrase: self.phrase, password: password, complete: {
                (success, mnemonic) in
                if !success {   //创建失败
                    SVProgressHUD.showError(withStatus: "Create wallet failed".localized())
                    return
                }
                
                //目前只有比特币钱包，创建默认的比特币钱包
                let wallet = CHBTCWallet.createWallet(mnemonic: mnemonic!)
                
                //创建默认HD账户
                let nickName = self.labelTextNickname.text
                guard let account = wallet.createHDAccount(by: nickName) else {
                    SVProgressHUD.showError(withStatus: "Create wallet account failed".localized())
                    return
                }
                
                //记录当前使用的比特币账户
                CHBTCWallet.sharedInstance.selectedAccountIndex = account.index
                
                self.gotoSuccessView()
            })
            
        }
    }
    
    func gotoSuccessView() {
        guard let vc = StoryBoard.welcome.initView(type: WelcomeSuccessViewController.self) else {
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /// 关闭键盘
    ///
    /// - Parameter sender:
    @IBAction func closeKeyboard(sender: AnyObject?) {
        AppDelegate.sharedInstance().closeKeyBoard()
    }
}

// MARK: - 实现输入框代理方法
extension WelcomeCreateAccountViewController: CHLabelTextFieldDelegate {
    
    func textFieldShouldReturn(_ ltf: CHLabelTextField) -> Bool {
        if ltf.textField === self.labelTextNickname.textField {
            self.labelTextPassword.textField?.becomeFirstResponder()
        } else if ltf.textField === self.labelTextPassword.textField {
            self.labelTextConfirm.textField?.becomeFirstResponder()
        } else if ltf.textField === self.labelTextConfirm.textField {
            ltf.textField?.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ ltf: CHLabelTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharOfPassword = 50
        
        if(ltf.textField === self.labelTextNickname.textField
            || ltf.textField === self.labelTextPassword.textField
            || ltf.textField === self.labelTextConfirm.textField) {
            if (range.location>(maxCharOfPassword - 1)) {
                return false
            }
        }
        
        
        return true;
    }
    
}
