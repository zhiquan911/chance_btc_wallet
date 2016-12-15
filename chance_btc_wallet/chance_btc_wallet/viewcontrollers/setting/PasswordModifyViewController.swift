//
//  PasswordModifyViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/2/1.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class PasswordModifyViewController: BaseTableViewController {
    
    //MARK: - 成员变量
    @IBOutlet var textFieldNewPassword: UITextField!
    @IBOutlet var textFieldConfirmPassword: UITextField!
    @IBOutlet var buttonSave: UIButton!
    
    @IBOutlet var tableViewCellNewPassword: UITableViewCell!
    @IBOutlet var tableViewCellConfirmPassword: UITableViewCell!
    
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
extension PasswordModifyViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Reset password".localized()

    }
    
    //检测输入值是否合法
    func checkValue() -> Bool {
        
        if self.textFieldNewPassword.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "New password is empty".localized())
            return false
        }
        if self.textFieldConfirmPassword.text != self.textFieldNewPassword.text! {
            SVProgressHUD.showInfo(withStatus: "Passwords is different".localized())
            return false
        }
        
        return true
    }
    
    /**
     点击保存
     
     - parameter sender:
     */
    @IBAction func handleSavePress(_ sender: AnyObject?) {
        if self.checkValue() {
//            let password = self.textFieldNewPassword.text!.trim()
//            CHWalletWrapper.password = password
//            SVProgressHUD.showSuccess(withStatus: "Password reset successed".localized())
//            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
}

// MARK: - 文本输入框代理方法
extension PasswordModifyViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldNewPassword {
            textFieldConfirmPassword.becomeFirstResponder()
        } else if textField == self.textFieldConfirmPassword {
            textFieldConfirmPassword.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharOfPassword = 50
        
        if(textField == self.textFieldNewPassword
            || textField == self.textFieldConfirmPassword) {
                if (range.location>(maxCharOfPassword - 1)) {
                    return false
                }
        }
        
        
        return true;
    }
    
}

extension PasswordModifyViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.tableViewCellNewPassword
        } else {
            return self.tableViewCellConfirmPassword
        }
    }
}
