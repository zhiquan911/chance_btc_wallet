//
//  WelcomeHDViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/4/16.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class WelcomeHDViewController: UIViewController {

    /// MARK: - 成员变量
    @IBOutlet var buttonRecovery: UIButton!
    @IBOutlet var buttonCreateNewWallet: UIButton!
    @IBOutlet var labelNote: UILabel!
    
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
