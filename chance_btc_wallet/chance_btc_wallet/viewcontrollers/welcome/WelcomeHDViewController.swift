//
//  WelcomeHDViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/16.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class WelcomeHDViewController: BaseViewController {

    /// MARK: - 成员变量
    @IBOutlet var buttonRecovery: UIButton!
    @IBOutlet var buttonCreateNewWallet: UIButton!
    @IBOutlet var labelNote: UILabel!
    
    @IBOutlet var tableViewCreateWalletMode: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Wallet".localized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 控制器方法
extension WelcomeHDViewController {
    
    /**
     点击导出私钥
     
     - parameter sender:
     */
    @IBAction func handlRecoveryPress(_ sender: AnyObject?) {
        guard let vc = StoryBoard.setting.initView(type: RestoreWalletViewController.self) else {
            return
        }
        vc.restoreOperateType = .passiveRestore
        vc.navigationItem.title = "Restore wallet".localized()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     点击创建新钱包
     
     - parameter sender:
     */
    @IBAction func handleCreateNewWalletPress(_ sender: AnyObject?) {
        guard let vc = StoryBoard.welcome.initView(type: WelcomePhraseViewController.self) else {
            return
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


// MARK: - 实现表格委托方法
extension WelcomeHDViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: WalletCreateModeCell
        cell = tableView.dequeueReusableCell(withIdentifier: WalletCreateModeCell.cellIdentifier) as! WalletCreateModeCell
    
        switch indexPath.section {
        case 0:             //恢复钱包，如果有icloud同时恢复用户体系数据
            cell.labelTitle.text = "Restore Wallet By Passphrases".localized()
            cell.labelAbstract.text = "If you remember your passphrase, use this to restore wallet.".localized()
            cell.imageViewMode.image = UIImage(named: "icon_restore")
        case 1:             //创建新钱包，用随机密语
            cell.labelTitle.text = "Create New Wallet".localized()
            cell.labelAbstract.text = "Use BIP39's random mnemonic code to create a new wallet.".localized()
            cell.imageViewMode.image = UIImage(named: "icon_create")
        default:break
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            self.handlRecoveryPress(nil)
        case 1:
            self.handleCreateNewWalletPress(nil)
        default:break
            
        }
    }
    
}
