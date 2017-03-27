//
//  CreateHDAccountViewController.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/2.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

class CreateHDAccountViewController: UIViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var buttonConfirm: UIButton!
    @IBOutlet var labelTextNickname: CHLabelTextField!
    @IBOutlet var labelTitle: UILabel!
    
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
extension CreateHDAccountViewController {
    
    func setupUI() {
        self.navigationItem.title = "Create Acount".localized()
        self.labelTitle.text = "Create HD Acount".localized()
        
        self.labelTextNickname.title = "Account Nickname".localized()
        self.labelTextNickname.placeholder = "Give your account a nickname".localized()
        self.labelTextNickname.textField?.keyboardType = .default
        self.labelTextNickname.delegate = self
        
        self.buttonConfirm.setTitle("Create".localized(), for: [.normal])
    }
    
    //检测输入值是否合法
    func checkValue() -> Bool {
        if self.labelTextNickname.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Username is empty".localized())
            
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
            
            //创建默认HD账户
            let nickName = self.labelTextNickname.text
            guard let account = CHBTCWallet.sharedInstance.createHDAccount(by: nickName) else {
                SVProgressHUD.showError(withStatus: "Create wallet account failed".localized())
                return
            }
            
            CHBTCWallet.sharedInstance.selectedAccountIndex = account.index
            
            //同时记录钱包界面最新的用户索引位
            WalletViewController.selectedCardIndex = account.index
            WalletViewController.scrollCardAnimated = true
            
            SVProgressHUD.showSuccess(withStatus: "Create account successfully!")
            _ = self.navigationController?.popViewController(animated: true)
        
        }
    }
}

// MARK: - 实现输入框代理方法
extension CreateHDAccountViewController: CHLabelTextFieldDelegate {
    
    func textFieldShouldReturn(_ ltf: CHLabelTextField) -> Bool {
        ltf.textField?.resignFirstResponder()
        return true
    }
    
    func textField(_ ltf: CHLabelTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharOfName = 50
        
        if(ltf.textField === self.labelTextNickname.textField) {
            if (range.location>(maxCharOfName - 1)) {
                return false
            }
        }
        
        
        return true;
    }
    
}
