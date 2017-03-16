//
//  WelcomePhraseViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/16.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class WelcomePhraseViewController: BaseViewController {

    /// MARK: - 成员变量
    @IBOutlet var buttonRebuild: UIButton!
    @IBOutlet var buttonNext: UIButton!
    @IBOutlet var textViewPhrase: UITextView!
    @IBOutlet var labelTips: UILabel!
    
    var phrase = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.createPassphrase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - 控制器方法
extension WelcomePhraseViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Recovery Phase".localized()

        self.labelTips.text = "Please mark down this passphrase and safe keeping. Don’t give them to anybody. You can restore wallet by this passphrase when you lose you wallet.".localized()
        self.buttonRebuild.setTitle("Change".localized(), for: .normal)
        self.buttonNext.setTitle("Next".localized(), for: .normal)
        
    }
    
    /**
     获取随机密语
     */
    func createPassphrase() {
        let mnemonic = CHWalletWrapper.generateMnemonicPassphrase()
        let phrase = CHWalletWrapper.getPassphraseByMnemonic(mnemonic!)
        self.textViewPhrase.text = phrase
        self.phrase = phrase
    }
    
    /**
     点击生成密语
     
     - parameter sender:
     */
    @IBAction func handleCreatePhrasePress(_ sender: AnyObject?) {
        self.createPassphrase()
    }
    
    /**
     点击下一步
     
     - parameter sender:
     */
    @IBAction func handleNextPress(_ sender: AnyObject?) {
        guard let vc = StoryBoard.welcome.initView(type: WelcomeCreateAccountViewController.self) else {
            return
        }
        vc.phrase = self.phrase
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
