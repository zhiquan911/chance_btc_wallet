//
//  BTCSendMultiSigViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/28.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class BTCSendMultiSigViewController: UIViewController {
    
    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonCopy: UIButton!
    
    var transactionHex: String!
    var redeemScriptHex: String!
    var multiSigHexs: String = ""
    var mySignatureHex: String = ""
    var sendText = ""
    var currentAccount: CHBTCAcounts!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.initSendText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - 控制器方法
extension BTCSendMultiSigViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Sign Transaction".localized()
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
        //按钮圆角
        self.buttonCopy.layer.cornerRadius = 3
        self.buttonCopy.layer.masksToBounds = true
        self.buttonCopy.setBackgroundImage(
            UIColor.imageWithColor(UIColor(hex: 0xE10B17)),
            for: UIControlState())
    }
    
    func initSendText() {
        //获取赎回脚本公钥的顺序列表
        let redeemScript = BTCScript(hex: redeemScriptHex)
        let pubkeys = redeemScript?.getMultisigPublicKeys()
        
        let index = pubkeys!.1.index(of: self.currentAccount.extendedPublicKey)
        let number = String(format:"%02x", index!)
        
        if multiSigHexs.isEmpty {
            multiSigHexs = "\(number)\(mySignatureHex)"
        } else {
            multiSigHexs = "\(multiSigHexs)|\(number)\(mySignatureHex)"
        }
        sendText = "\(transactionHex)&\(multiSigHexs)&\(redeemScriptHex)"
        
        self.labelTransactionHex.text = sendText
    }
    
    /**
     点击复制
     
     - parameter sender: 
     */
    @IBAction func handleCopyPress(_ sender: AnyObject?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = sendText
        SVProgressHUD.showSuccess(withStatus: "Text copied".localized())
    }
}
