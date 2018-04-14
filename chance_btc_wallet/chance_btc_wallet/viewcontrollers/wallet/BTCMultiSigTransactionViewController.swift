//
//  BTCMultiSigTransactionViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit


/*
 因为本钱包都是P2P的转账交易。
 所以待签名的交易单都是只有1个发送方和1个接收方。
 以后如果开发批量发送的交易单，将会以另一种界面形式呈现
 */
class BTCMultiSigTransactionViewController: BaseViewController {
    
//    @IBOutlet var labelTransactionHex: UILabel!
    @IBOutlet var buttonSign: UIButton!
    @IBOutlet var labelTextSender: CHLabelTextField!
    @IBOutlet var labelTextReceiver: CHLabelTextField!
    @IBOutlet var labelTextSignature: CHLabelTextField!
    @IBOutlet var labelTextAmount: CHLabelTextField!
//    @IBOutlet var labelTextFees: CHLabelTextField!
    
    var currentAccount: CHBTCAcount!
    
    var multiSigTx: MultiSigTransaction!
    var currencyType: CurrencyType = .BTC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showMutilSigTxToForm()
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
        
        self.navigationItem.title = "Contract".localized()
        
        self.labelTextSender.title = "The Sender".localized()
        self.labelTextReceiver.title = "The Receiver".localized()
        self.labelTextAmount.title = "Transfer Amount".localized() + "(\(self.currencyType.rawValue))"
//        self.labelTextFees.title = "Fees".localized() + "(\(self.currencyType.rawValue))"
        self.labelTextSignature.title = "Signatures / Required Keys".localized()
        
        self.buttonSign.setTitle("Agree To Sign".localized(), for: .normal)
        
        
    }
    
    
    /// 解析多重签名交易协议成显示的表单内容
    func showMutilSigTxToForm() {
        guard let tx = BTCTransaction(hex: self.multiSigTx.rawTx) else {
            //错误提示
            return
        }
        
        guard let rs = self.multiSigTx.redeemScriptHex.toBTCScript() else {
            return
        }
        
        switch CHWalletWrapper.selectedBlockchainNetwork {
        case .main:
            self.labelTextSender.text = rs.scriptHashAddress.string
        case .test:
            self.labelTextSender.text = rs.scriptHashAddressTestnet.string
        }
        
        //转账数量 = 输出方的数量
        if tx.outputs.count > 0 {
            let output = tx.outputs[0] as! BTCTransactionOutput
            
            self.labelTextAmount.text = output.value.toBTC()
            
            switch CHWalletWrapper.selectedBlockchainNetwork {
            case .main:
                self.labelTextReceiver.text = output.script.standardAddress.string
            case .test:
                self.labelTextReceiver.text = BTCPublicKeyAddressTestnet(data: output.script.standardAddress.data)?.string ?? ""
            }
            
        }
        
        
        //签名进度
        let signed = self.multiSigTx.keySignatures?.count ?? 0
        let required = rs.requiredSignatures
        let text = "\(signed) / \(required)"
        self.labelTextSignature.text = text
        
        //已签的改为另一个颜色
        let attributedStr = NSMutableAttributedString(string: text)
        let newRange = NSMakeRange(0, signed.toString().length)
        let colorDict = [NSAttributedStringKey.foregroundColor: UIColor(hex: 0xFF230D)]
        attributedStr.addAttributes(colorDict, range: newRange)
        self.labelTextSignature.textField?.attributedText = attributedStr
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
            let index = signHex.index(signHex.startIndex, offsetBy: 2)
            let dataHex = String(signHex[index...])
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
                        Log.debug("tx.hex = \(String(describing: tx?.hex))")
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
        SVProgressHUD.show()
        let nodeServer = CHWalletWrapper.selectedBlockchainNode.service
        nodeServer.sendTransaction(transactionHexString: tx.hex) {
            (message, txid) -> Void in
            if message.code == ApiResultCode.Success.rawValue {
                SVProgressHUD.showSuccess(withStatus: "Transaction successed，waiting confirm".localized())
                _ = self.navigationController?.popToRootViewController(animated: true)
            } else {
                SVProgressHUD.showError(withStatus: message.message)
            }
        }
    }
}
