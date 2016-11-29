//
//  PasswordSettingViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/2/1.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class PasswordSettingViewController: UITableViewController {

    /// MARK - 成员变量
    @IBOutlet var switchTouchID: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.switchTouchID.isOn = CHWalletWrapper.enableTouchID
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                guard let vc = StoryBoard.setting.initView(type: PasswordModifyViewController.self) else {
                    return
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /**
     配置导航栏
     */
    func setupUI() {
        self.navigationItem.title = "Security Center".localized()
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        let result = TouchIDUtils.isTouchIDEnable()
        if result.0 {
            self.switchTouchID.isEnabled = true
        } else {
            self.switchTouchID.isEnabled = false
        }
    }
    
    /**
     切换开关
     
     - parameter sender:
     */
    @IBAction func handleSwitchValueChange(_ sender: UISwitch) {
        
        CHWalletWrapper.enableTouchID = sender.isOn
    }
    

}
