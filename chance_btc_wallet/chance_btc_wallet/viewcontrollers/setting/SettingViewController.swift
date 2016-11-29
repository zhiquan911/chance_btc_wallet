//
//  SettingViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/26.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class SettingViewController: BaseTableViewController {
    
    var currentAccount: CHBTCAcounts? {
        let i = CHWalletWrapper.selectedAccountIndex
        if i != -1 {
            return CHBTCWallets.sharedInstance.getAccount(i)
        } else {
            return nil
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            
            if let account = self.currentAccount {
                if account.accountType == .MultiSig {
                    return 3
                } else {
                    return 2
                }
            } else {
                return 0
            }

        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let doBlock = {
            () -> Void in
            
            var title = ""
            if indexPath.section == 0 {
                var keyType = ExportKeyType.PublicKey
                if indexPath.row == 0 {
                    keyType = ExportKeyType.PublicKey
                    title = "Export account's public key".localized()
                } else if indexPath.row == 1 {
                    keyType = ExportKeyType.PrivateKey
                    title = "Export account's private key".localized()
                } else if indexPath.row == 2 {
                    keyType = ExportKeyType.RedeemScript
                    title = "Export account's redeemScript".localized()
                }
                
                guard let vc = StoryBoard.setting.initView(type: ExportKeyViewController.self) else {
                    return
                }
                vc.currentAccount = self.currentAccount!
                vc.keyType = keyType
                vc.navigationItem.title = title
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.section == 1 {
                var isRestore = false
                var title = ""
                if indexPath.row == 0 {
                    isRestore = false
                    title = "Export wallet's Mnemonic phases".localized()
                } else {
                    isRestore = true
                    title = "Restore wallet by Mnemonic phases".localized()
                }
                
                guard let vc = StoryBoard.setting.initView(type: RestoreWalletViewController.self) else {
                    return
                }
                vc.isRestore = isRestore
                vc.navigationItem.title = title
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    
                    guard let vc = StoryBoard.setting.initView(type: PasswordSettingViewController.self) else {
                        return
                    }
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if indexPath.section == 3 {
                SVProgressHUD.showInfo(withStatus: "Coming soon".localized())
            } else if indexPath.section == 4 {
                SVProgressHUD.showInfo(withStatus: "Coming soon".localized())
            }
            
        }
        
        switch indexPath.section {
        case 0, 1, 2: //需要密码
            
            //需要提供指纹密码
            CHWalletWrapper.unlock(vc: self, complete: {
                (flag, error) in
                if flag {
                    doBlock()
                } else {
                    if error != "" {
                        SVProgressHUD.showError(withStatus: error)
                    }
                }
            })
            
        default:        //默认不需要密码
            doBlock()
        }
        
        
        

    }
}

// MARK: - 控制器方法
extension SettingViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Setting".localized()
        
    }
    
}
