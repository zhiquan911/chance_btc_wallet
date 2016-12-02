//
//  MultiSigAccountCreateViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/27.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class MultiSigAccountCreateViewController: BaseTableViewController {
    
    @IBOutlet var textFieldTotalKeys: UITextField!
    @IBOutlet var textFieldRequiredKeys: UITextField!
    @IBOutlet var textFieldUserName: UITextField!
    @IBOutlet var buttonNext: UIButton!

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
extension MultiSigAccountCreateViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Create Multi-Sig account".localized()

    }
    
    /**
     点击下一步
     
     - parameter sender:
     */
    @IBAction func handleNextPress(_ sender: AnyObject?) {
        if self.checkValue() {
            guard let vc = StoryBoard.account.initView(type: MultiSigInputKeyViewController.self) else {
                return
            }
            vc.keyCount = self.textFieldTotalKeys.text!.toInt()
            vc.requiredCount = self.textFieldRequiredKeys.text!.toInt()
            vc.userName = self.textFieldUserName.text
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
     检查值
     
     - returns:
     */
    func checkValue() -> Bool {
        if self.textFieldUserName.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Username is empty".localized())
            
            return false
        }
        
        if self.textFieldTotalKeys.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Input how many keys to create".localized())
            return false
        }
        
        if self.textFieldRequiredKeys.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Input how many signatures that account required".localized())
            return false
        }
        
        if self.textFieldTotalKeys.text!.toInt() <= 1 {
            SVProgressHUD.showInfo(withStatus: "The amount of keys should more then 1".localized())
            return false
        }
        
        if self.textFieldRequiredKeys.text!.toInt() > self.textFieldTotalKeys.text!.toInt() {
            SVProgressHUD.showInfo(withStatus: "The amount of signatures can not more then the amount of keys".localized())
            return false
        }
        
        return true
    }
}

// MARK: - 文本代理方法
extension MultiSigAccountCreateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
