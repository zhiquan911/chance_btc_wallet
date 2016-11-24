//
//  BTCMultiSigTransactionViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/28.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class BTCMultiSigTransactionViewController: UIViewController {
    
    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonSign: UIButton!
    
    var transactionHex: String!
    var multiSigHexs: String!
    var redeemScriptHex: String!
    var messageHex: String!
    var currentAccount: CHBTCAcounts!
    var signatureDic = [Int: Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.labelTransactionHex.text = self.transactionHex
        self.signatureDic = self.getSignArray(multiSigHexs)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - 控制器方法
extension BTCMultiSigTransactionViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Complete signature".localized()
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
        //按钮圆角
        self.buttonSign.layer.cornerRadius = 3
        self.buttonSign.layer.masksToBounds = true
        self.buttonSign.setBackgroundImage(
            UIColor.imageWithColor(UIColor(hex: 0xE10B17)),
            for: UIControlState())
    }
    
    /**
     把之前其他人的签名按顺序解析出来
     
     - parameter sigstring:
     
     - returns:
     */
    func getSignArray(_ sigstring: String) -> [Int: Data] {
        var dic = [Int: Data]()
        let signsArray = sigstring.components(separatedBy: "|")
        for signHex in signsArray {
            //获取头部的序号
            let header = "0x\(signHex.substring(0, length: 2)!)"
            let index = signHex.characters.index(signHex.startIndex, offsetBy: 2)
            let dataHex = signHex.substring(from: index)
            let seq = strtoul(header,nil,16)
            dic[Int(seq)] = BTCDataFromHex(dataHex)
        }
        return dic
    }
    
    /**
     按赎回脚本添加签名
     
     - parameter data:
     
     - returns:
     */
    func addSignatureByRedeemOrder(_ data: Data) -> BTCScript {
        let allSignData: BTCScript = BTCScript()
        _ = allSignData.append(BTCOpcode.OP_0)
        //获取赎回脚本公钥的顺序列表
        let redeemScript = BTCScript(hex: redeemScriptHex)
        let pubkeys = redeemScript?.getMultisigPublicKeys()
        
        //把自己的签名加入到签名数组中
        
        let myIndex = pubkeys!.1.index(of: self.currentAccount.publicKey.address.string)!
        self.signatureDic[myIndex] = data
        
        //按顺序合并签名数据
        let number = self.signatureDic.keys.sorted(by: <)
        for n in number {
            let sigdata = self.signatureDic[n]
            _ = allSignData.appendData(sigdata!)
        }
        return allSignData
    }
    
    /**
     点击复制
     
     - parameter sender:
     */
    @IBAction func handleSignPress(_ sender: AnyObject?) {
        
        let doBlock = {
            () -> Void in
            //签名HEX
            var signatureHex = ""
            
            let tx = BTCTransaction(hex: self.transactionHex)
            let redeemScript = BTCScript(hex: self.redeemScriptHex)
            var isComplete = true
            for i in 0 ..< (tx?.inputs.count)! {
                let txin = tx?.inputs[i] as! BTCTransactionInput
                let hashtype = BTCSignatureHashType.BTCSignatureHashTypeAll
                //多重签名的地址要用赎回脚本
                let hash = try? tx?.signatureHash(for: redeemScript, inputIndex: UInt32(i), hashType: hashtype)
                if hash == nil {
                    SVProgressHUD.showError(withStatus: "Signature error".localized())
                } else {
                    
                    
                    
                    //                    let sigScript = txin.signatureScript
                    
                    let key = self.currentAccount.privateKey
                    let signature = key?.signature(forHash: hash!, hashType: hashtype)
                    signatureHex = (signature! as NSData).hex()
                    //                    sigScript.appendData(signature)
                    
                    //按赎回脚本的生成顺序一次添加签名
                    let sigScript = self.addSignatureByRedeemOrder(signature!)
                    
                    txin.signatureScript = sigScript
                    Log.debug("signatureScript = \(txin.signatureScript)")
                    //验证交易是否签名完成
                    do {
                        let sm = BTCScriptMachine(transaction: tx, inputIndex: UInt32(i))
                        try sm?.verify(withOutputScript: redeemScript)
                        txin.signatureScript.appendData(redeemScript?.data)
                    } catch let error as NSError {
                        Log.debug("error = \(error.description)")
                        Log.debug("tx.hex = \(tx?.hex)")
                        //验证不通过，还需要继续签名
                        isComplete = false
                        
                    }
                }
            }
            
            if isComplete {
                self.sendTransactionByWebservice(tx!)
            } else {
                self.gotoSendTransactionHexView(signatureHex)
            }
        }
        
        //解锁才能继续操作
        CHWalletWrapper.unlock(
            vc: self,
            complete: {
                (flag, error) in
                if flag {
                    doBlock()
                } else {
                    if error != "" {
                        SVProgressHUD.showError(withStatus: error)
                    }
                }
        })
        
        
    }
    
    /**
     进入复制交易文本界面
     
     - parameter tx:
     */
    func gotoSendTransactionHexView(_ signatureHex: String) {
        guard let vc = StoryBoard.wallet.initView(type: BTCSendMultiSigViewController.self) else {
            return
        }
        vc.transactionHex = self.transactionHex
        vc.mySignatureHex = signatureHex
        vc.multiSigHexs = multiSigHexs
        vc.redeemScriptHex = self.redeemScriptHex
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     调用接口广播交易
     
     - parameter tx:
     */
    func sendTransactionByWebservice(_ tx: BTCTransaction) {
        BlockchainRemoteService.sharedInstance.sendTransaction(transactionHexString: tx.hex) {
            (message, txid) -> Void in
            if message.code == ApiResultCode.Success.rawValue {
                SVProgressHUD.showSuccess(withStatus: "Transaction successed，waiting confirm".localized())
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                SVProgressHUD.showError(withStatus: message.message)
            }
        }
    }
}
