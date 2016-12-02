//
//  WelcomePhraseViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/16.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class WelcomePhraseViewController: UIViewController {

    /// MARK: - 成员变量
    @IBOutlet var buttonRebuild: UIButton!
    @IBOutlet var buttonNext: UIButton!
    @IBOutlet var textViewPhrase: UITextView!
    
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
        
        self.textViewPhrase.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        self.textViewPhrase.layer.borderWidth = 0.65;
        self.textViewPhrase.layer.cornerRadius = 6.0;
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
