//
//  BTCMultiSigTransactionViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class BTCMultiSigTransactionViewController: UIViewController {
    
    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonSign: UIButton!
    
    var currentAccount: CHBTCAcount!
    var multiSigTx: MultiSigTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.labelTransactionHex.text = self.multiSigTx.rawTx
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
    
    
    /// 把对交易表单输入为i的签名添加有序的多重签名
    ///
    /// - Parameters:
    ///   - hex: 签名hex
    ///   - inputIndex: 交易输入位
    /// - Returns: 签名后的脚本
    func addSignatureByRedeemOrder(hex: String, inputIndex: Int) -> BTCScript {
        let allSignData: BTCScript = BTCScript()
        
        //添加脚本第一个命令
        _ = allSignData.append(BTCOpcode.OP_0)
        
        //查找自己账户公钥地址在赎回脚本中的位置
        let myIndex = self.currentAccount.index(of: BTCScript(hex: self.multiSigTx.redeemScriptHex)!).toString()
        
        //添加签名到自己的位置
        var mySignatures = self.multiSigTx.keySignatures![myIndex] ?? [String]()
        if !mySignatures.contains(hex) {
            mySignatures.append(hex)    //除掉重复
        }
        
        
        //同时改变原来的表单结构体内的签名部分，添加当前账户的签名数据和位置
        self.multiSigTx.keySignatures![myIndex] = mySignatures
        
        //按顺序合并签名数据
        let number = self.multiSigTx.keySignatures!.keys.sorted(by: <)
        for n in number {
            let sigHex = self.multiSigTx.keySignatures![n]![inputIndex]
            _ = allSignData.appendData(BTCDataFromHex(sigHex))
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
            var signatureHexs = [String]()
            
            let tx = BTCTransaction(hex: self.multiSigTx.rawTx)
            let redeemScript = BTCScript(hex: self.multiSigTx.redeemScriptHex)
            var isComplete = true
            for i in 0 ..< tx!.inputs.count {
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
                    let tmpSinsignatureHex = (signature! as NSData).hex()
                    signatureHexs.append(tmpSinsignatureHex!)   //添加签名到数组
                    
                    //按赎回脚本的生成顺序一次添加签名
                    let sigScript = self.addSignatureByRedeemOrder(hex: tmpSinsignatureHex!, inputIndex: i)
                    
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
                self.gotoSendTransactionHexView(signatureHexs)
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
    func gotoSendTransactionHexView(_ signatureHex: [String]) {
        guard let vc = StoryBoard.wallet.initView(type: BTCSendMultiSigViewController.self) else {
            return
        }
        
        vc.currentAccount = self.currentAccount
        vc.multiSigTx = self.multiSigTx
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     调用接口广播交易
     
     - parameter tx:
     */
    func sendTransactionByWebservice(_ tx: BTCTransaction) {
        let nodeServer = CHWalletWrapper.selectedBlockchainNode.service
        nodeServer.sendTransaction(transactionHexString: tx.hex) {
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
