//
//  MultiSigAccountCreateViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/27.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class MultiSigAccountCreateViewController: BaseViewController {
    
    @IBOutlet var labelTextNickname: CHLabelTextField!
    @IBOutlet var sliderKeys: UISlider!
    @IBOutlet var sliderRequired: UISlider!
    @IBOutlet var buttonNext: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelKeys: UILabel!
    @IBOutlet var labelRequired: UILabel!
    @IBOutlet var labelKeysTitle: UILabel!
    @IBOutlet var labelRequiredTitle: UILabel!
    
    let minKeys: Int = 2
    let maxKeys: Int = 16
    
    ///最小选择的钥匙数目2条
    var selectedkeys: Int = 2 {
        didSet {
            self.labelKeys.text = self.selectedkeys.toString()
        }
    }
    
    
    /// 必要的签名数最少1
    var selectedRequired: Int = 1 {
        didSet {
            self.labelRequired.text = self.selectedRequired.toString()
        }
    }
    
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
        
        self.navigationItem.title = "Create Account".localized()

        self.labelTitle.text = "Create Multi-Sig Acount".localized()
        
        self.labelTextNickname.title = "Account Nickname".localized()
        self.labelTextNickname.placeholder = "Give your account a nickname".localized()
        self.labelTextNickname.textField?.keyboardType = .default
        self.labelTextNickname.delegate = self
        self.labelKeysTitle.text = "How many keys you want?".localized()
        self.labelRequiredTitle.text = "How many signatures required of keys?".localized()
        
        self.buttonNext.setTitle("Next".localized(), for: [.normal])
        
        self.sliderKeys.minimumValue = self.minKeys.toFloat()
        self.sliderKeys.maximumValue = self.maxKeys.toFloat()
        self.sliderKeys.value = self.minKeys.toFloat()
        self.labelKeys.text = self.selectedkeys.toString()
        self.sliderRequired.minimumValue = self.minKeys.toFloat() - 1
        self.sliderRequired.maximumValue = self.maxKeys.toFloat()
        self.sliderRequired.value = self.minKeys.toFloat() - 1
        self.labelRequired.text = self.selectedRequired.toString()
        
    }
    
    /**
     点击下一步
     
     - parameter sender:
     */
    @IBAction func handleNextPress(_ sender: AnyObject?) {
        AppDelegate.sharedInstance().closeKeyBoard()
        if self.checkValue() {
            guard let vc = StoryBoard.account.initView(type: MultiSigInputKeyViewController.self) else {
                return
            }
            vc.keyCount = self.selectedkeys
            vc.requiredCount = self.selectedRequired
            vc.userName = self.labelTextNickname.text
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
     检查值
     
     - returns:
     */
    func checkValue() -> Bool {
        if self.labelTextNickname.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Username is empty".localized())
            
            return false
        }
        
//        if self.textFieldTotalKeys.text!.isEmpty {
//            SVProgressHUD.showInfo(withStatus: "Input how many keys to create".localized())
//            return false
//        }
//        
//        if self.textFieldRequiredKeys.text!.isEmpty {
//            SVProgressHUD.showInfo(withStatus: "Input how many signatures that account required".localized())
//            return false
//        }
//        
//        if self.textFieldTotalKeys.text!.toInt() <= 1 {
//            SVProgressHUD.showInfo(withStatus: "The amount of keys should more then 1".localized())
//            return false
//        }
//        
        if self.selectedRequired > self.selectedkeys {
            SVProgressHUD.showInfo(withStatus: "The amount of signatures can not more then the amount of keys".localized())
            return false
        }
        
        return true
    }
    
    @IBAction func handleSliderValueChange(sender: UISlider) {
        
        if sender === self.sliderKeys {
            self.selectedkeys = lroundf(sender.value)
        } else if sender === self.sliderRequired {
            self.selectedRequired = lroundf(sender.value)
        }
    }
}

// MARK: - 文本代理方法
extension MultiSigAccountCreateViewController: CHLabelTextFieldDelegate {
    
    func textFieldShouldReturn(_ ltf: CHLabelTextField) -> Bool {
        ltf.textField?.resignFirstResponder()
        return true
    }
}
