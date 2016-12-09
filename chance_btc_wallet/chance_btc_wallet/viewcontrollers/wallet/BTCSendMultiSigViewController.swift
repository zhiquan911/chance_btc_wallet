//
//  BTCSendMultiSigViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class BTCSendMultiSigViewController: UIViewController {
    
    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonCopy: UIButton!
    
    var currentAccount: CHBTCAcount!
    var multiSigTx: MultiSigTransaction!
    
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
    
        self.labelTransactionHex.text = self.multiSigTx.json
    }
    
    /**
     点击复制
     
     - parameter sender: 
     */
    @IBAction func handleCopyPress(_ sender: AnyObject?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.multiSigTx.json
        SVProgressHUD.showSuccess(withStatus: "Text copied".localized())
    }
}
