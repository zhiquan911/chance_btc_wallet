//
//  BTCSendMultiSigViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class BTCSendMultiSigViewController: BaseViewController {
    
    @IBOutlet var labelTips: UILabel!
    @IBOutlet var stackViewPedding: UIStackView!
    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonRequest: UIButton!
    @IBOutlet var buttonFinish: UIButton!
    
    var currentAccount: CHBTCAcount!
    var multiSigTx: MultiSigTransaction!
    
    let kHeightOfItem: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showTransactionForm()
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
        
        self.navigationItem.title = "Multi-Sig Request".localized()
        self.labelTips.text = "Transaction has been created. Require the following address's private key signature:".localized()
        
        self.buttonRequest.setTitle("Request Signature", for: .normal)
        self.buttonFinish.setTitle("Finish", for: .normal)
    }
    
    
    /// 显示交易表单需要的签名
    func showTransactionForm() {
        guard let script = self.multiSigTx.redeemScriptHex.toBTCScript() else {
            return
        }
        
        guard let (_, adds) = script.getMultisigPublicKeys() else {
            return
        }
        
        //已签名的地址位置
        let hasSigned = self.multiSigTx.keySignatures!.keys
        
        //未签名的地址
        var unsignedAdds = adds
        
        //提出本身签名者的签名
        //adds.removeObject(self.currentAccount.accountId)
        
        //剔除已签名的，留下未签名的
        for index in hasSigned {
            let target = adds[index.toInt()]
            unsignedAdds.removeObject(target)
        }
        
        //罗列未签名的地址到StackView列表
        for address in unsignedAdds {
            let item = PeddingSignatureView()
            item.heightAnchor.constraint(equalToConstant: kHeightOfItem).isActive = true
            self.stackViewPedding.addArrangedSubview(item)
            
            item.address = address
        }
        
       
    }
    
    /**
     点击复制
     
     - parameter sender: 
     */
    @IBAction func handleRequestPress(_ sender: AnyObject?) {
        let text = self.multiSigTx.json
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func handleFinishPress(_ sender: AnyObject?) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
