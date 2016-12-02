//
//  CreateHDMAccountViewController.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/2.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

class CreateHDMAccountViewController: UIViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var buttonConfirm: UIButton!
    @IBOutlet var textFieldUserName: UITextField!
    
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
extension CreateHDMAccountViewController {
    
    func setupUI() {
        self.navigationItem.title = "Create new HDM acount".localized()
    }
    
    //检测输入值是否合法
    func checkValue() -> Bool {
        if self.textFieldUserName.text!.isEmpty {
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
            let nickName = self.textFieldUserName.text!
            guard let account = CHBTCWallet.sharedInstance.createHDAccount(by: nickName) else {
                SVProgressHUD.showError(withStatus: "Create wallet account failed".localized())
                return
            }
            
            CHBTCWallet.sharedInstance.selectedAccountIndex = account.index
            
            SVProgressHUD.showSuccess(withStatus: "Create account successfully!")
            _ = self.navigationController?.popViewController(animated: true)
        
        }
    }
}

// MARK: - 实现输入框代理方法
extension CreateHDMAccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharOfName = 50
        
        if(textField == self.textFieldUserName) {
            if (range.location>(maxCharOfName - 1)) {
                return false
            }
        }
        
        
        return true;
    }
    
}
