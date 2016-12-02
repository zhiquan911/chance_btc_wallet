//
//  SendViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/26.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class BTCSendViewController: UITableViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var labelAvailableTotal: UILabel!
    @IBOutlet var labelCurrency: UILabel!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var textFieldNumber: UITextField!
    @IBOutlet var textFieldNote: UITextField!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var buttonConfirm: UIButton!
    
    var currencyType = CurrencyType.BTC
    var addressNote = ""
    var fee: BTCAmount = 10000
    var address = ""
    var actualTotal: BTCAmount!
    var availableTotal: BTCAmount!
    var btcAccount: CHBTCAcount!
    var changeAddress: BTCAddress {
        return self.btcAccount.address
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.labelAvailableTotal.text = BTCAmount.stringWithSatoshiInBTCFormat(self.availableTotal)
        self.labelCurrency.text = currencyType.rawValue
        self.setupFee()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - 控制器方法
extension BTCSendViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Send".localized() + currencyType.rawValue
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
        //按钮圆角
        self.buttonConfirm.layer.cornerRadius = 3
        self.buttonConfirm.layer.masksToBounds = true
        self.buttonConfirm.setBackgroundImage(
            UIColor.imageWithColor(UIColor(hex: 0xE10B17)),
            for: UIControlState())
    }
    
    
    //设置矿工费信息
    func setupFee() {
        //手续费设置
        let number = self.textFieldNumber.text == "" ? "0" : self.textFieldNumber.text!
        self.actualTotal = BTCAmount.satoshiWithStringInBTCFormat(number)
        
        if self.actualTotal > self.availableTotal {
            self.actualTotal = self.availableTotal  - self.fee
            self.textFieldNumber.text = BTCAmount.stringWithSatoshiInBTCFormat(self.availableTotal)
        } else {
            self.actualTotal = self.actualTotal  - self.fee
        }
        
        self.actualTotal = self.actualTotal > 0 ? self.actualTotal : 0
        
        
        
        self.labelInfo.text = "Actual：".localized() + "\(BTCAmount.stringWithSatoshiInBTCFormat(self.actualTotal))\(self.currencyType.rawValue)，Fees：\(BTCAmount.stringWithSatoshiInBTCFormat(self.fee))\(self.currencyType.rawValue)"
    }
    
    /**
     点击地址
     
     - parameter sender:
     */
    @IBAction func handleAddressPress(_ sender: AnyObject?) {
        //收回键盘
        AppDelegate.sharedInstance().closeKeyBoard()
        
        let actionSheet = UIAlertController(title: "BTC Address".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Scan QRCode".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressScanViewController") as! AddressScanViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Paste from Clipboard".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if pasteboard.string?.length ?? 0 > 0 {
                self.labelAddress.textColor = UIColor.darkGray
                self.labelAddress.text = pasteboard.string
                self.address = pasteboard.string!
            } else {
                SVProgressHUD.showInfo(withStatus: "Clipboard is empty".localized())
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    /**
     进入复制交易文本界面
     
     - parameter tx:
     */
    func gotoSendTransactionHexView(_ tx: BTCTransaction, unsignTxHex: String, singnatureHex: String) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BTCSendMultiSigViewController") as! BTCSendMultiSigViewController
//        vc.transactionHex = unsignTxHex
//        vc.mySignatureHex = singnatureHex
//        vc.redeemScriptHex = BBKeyStore.sharedInstance.redeemScript!.hex
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /**
     选择历史打币地址
     
     - parameter sender:
     */
    @IBAction func handleAddressMorePress(_ sender: AnyObject?) {
        
        //收回键盘
        AppDelegate.sharedInstance().closeKeyBoard()
    }
    
    
    /**
     点击确认按钮
     
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
        AppDelegate.sharedInstance().closeKeyBoard()
        if self.checkValue() {
            SVProgressHUD.show(with: SVProgressHUDMaskType.black)
            
            let doBlock = {
                () -> Void in
                self.getUnspentTransactionByWebservice {
                    (tx, unsignTxHex, singnatureHex, message) -> Void in
                    if message.code == ApiResultCode.Success.rawValue {
                        self.sendTransactionByWebservice(tx!)
                    } else if message.code == ApiResultCode.NeedOtherSignature.rawValue {
                        //需要继续签名
                        SVProgressHUD.dismiss()
                        self.gotoSendTransactionHexView(tx!, unsignTxHex: unsignTxHex!, singnatureHex: singnatureHex!)
                    } else {
                        SVProgressHUD.showError(withStatus: message.message)
                    }
                }
                
            }
            
            //解锁才能继续操作
            CHWalletWrapper.unlock(vc: self,
                                   complete: {
                (flag, error) in
                    if flag {
                        doBlock()
                    } else {
                        if error != "" {
                            SVProgressHUD.showError(withStatus: error)
                        } else {
                            SVProgressHUD.dismiss()
                        }
                    }
            })
        }
        
    }
    
    //检测输入值是否合法
    func checkValue() -> Bool {
        if self.address.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Address is empty".localized())
            
            return false
        }
        
        if self.textFieldNumber.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Amount is empty".localized())
            return false
        }
        
        return true
    }
    
    /**
     获取未花的记录
     */
    func getUnspentTransactionByWebservice(
        _ completionHandler: @escaping (BTCTransaction?, String? , String?, MessageModule) -> Void) {
            BlockchainRemoteService.sharedInstance.userUnspentTransactions(address: self.changeAddress.string) {
                (message, unspentTxs) -> Void in
                if unspentTxs.count > 0 {
                    
                    var isComplete = true
                    
                    //付币总数
                    let totalAmount = self.actualTotal + self.fee
                    
                    var utxos = [BTCTransactionOutput]()
                    
                    for unspentTx in unspentTxs {
                        let txout = BTCTransactionOutput()
                        txout.value = unspentTx.amount
                        txout.script = BTCScript(hex: unspentTx.scriptPubKey)
                        txout.index = UInt32(unspentTx.vout)
                        txout.transactionHash = (BTCReversedData(BTCDataFromHex(unspentTx.txid)));
                        utxos.append(txout)
                    }
                    
                    utxos = utxos.sorted(by: { s1, s2 in s1.value < s2.value })
                    
                    var txouts = [BTCTransactionOutput]()
                    
                    var balance: BTCAmount = 0;
                    
                    for txout in utxos {
                        //如果是脚本是付币的，就累加，统计未花的余额总数
                        if (txout.script.isPayToPublicKeyHashScript
                            || txout.script.isPayToScriptHashScript) {
                                txouts.append(txout)
                                balance = balance + txout.value;
                        }
                        //未花的余额总数超过这次付币数量，就可以交易
                        if balance >= totalAmount {
                            break;
                        }
                    }
                    
                    // Check for insufficent funds.
                    if txouts.count == 0 || balance < totalAmount {
                        completionHandler(nil, nil, nil, MessageModule(code: "1001", message: "Balance not enough".localized()));
                    } else {
                        //创建新交易
                        let tx = BTCTransaction()
                        
                        var spentCoins: BTCAmount = 0
                        
                        //把未花的输出交易初始成新交易的输入
                        for txout in txouts {
                            let txin = BTCTransactionInput()
                            txin.previousHash = txout.transactionHash;
                            txin.previousIndex = txout.index;
                            tx.addInput(txin)
                            spentCoins += txout.value;
                        }
                        
                        //添加交易输出的地址及找零地址
                        let destinationAddress = BTCAddress(string: self.address)
                        let paymentOutput = BTCTransactionOutput(value: self.actualTotal, address: destinationAddress)
                        
                        tx.addOutput(paymentOutput)
                        
                        if (spentCoins - totalAmount > 0) {
                            let changeOutput = BTCTransactionOutput(value: spentCoins - totalAmount, address: self.changeAddress)
                            tx.addOutput(changeOutput)
                        }
                        
                        //先导出未签名的交易hex，多签时要隔离验证
                        let txHex = tx.hex
                        //签名HEX
                        var singnatureHex = ""
                        
                        //签名所有未花的输入交易脚本
                        for (i, _) in txouts.enumerated() {
                            let txout = txouts[i]      // 上一次交易的输出
                            let txin = tx.inputs[i] as! BTCTransactionInput    //本次交易的输入
                            let hashtype = BTCSignatureHashType.BTCSignatureHashTypeAll
                            let sigScript: BTCScript = BTCScript()
                            
                            let hash: Data?
                            
                            let hashScript: BTCScript
                            if self.btcAccount.accountType == .normal {
                                hashScript = txout.script
                            } else {
                                //多重签名的地址要用赎回脚本
                                hashScript = self.btcAccount.redeemScript!
                            }
                            
                            hash = try? tx.signatureHash(for: hashScript, inputIndex: UInt32(i), hashType: hashtype)
                            
                            if hash == nil {
                                completionHandler (nil, nil, nil, MessageModule(code: "1001", message: "transaction hash failed".localized()));
                                return;
                            } else {
                                let key = self.btcAccount.privateKey!
                                let signature = key.signature(forHash: hash, hashType: hashtype)!
                                singnatureHex = (signature as NSData).hex()
                                
                                let redeemScriptData: Data
                                if self.btcAccount.accountType == .normal {
                                    _ = sigScript.appendData(signature)
                                    redeemScriptData = key.publicKey as Data
                                } else {
                                    _ = sigScript.append(BTCOpcode.OP_0)
                                    _ = sigScript.appendData(signature)
                                    //多重签名的地址要用赎回脚本
                                    redeemScriptData = self.btcAccount.redeemScript!.data
                                }
                                
                                //添加签名后的数据
                                txin.signatureScript = sigScript
                                //验证交易是否签名完成
                                do {
                                    let sm: BTCScriptMachine
                                    if self.btcAccount.accountType == .normal {
                                        txin.signatureScript.appendData(redeemScriptData)
                                        sm = BTCScriptMachine(transaction: tx, inputIndex: UInt32(i))
                                        try sm.verify(withOutputScript: hashScript)
                                    } else {
                                        sm = BTCScriptMachine(transaction: tx, inputIndex: UInt32(i))
                                        try sm.verify(withOutputScript: hashScript)
                                        txin.signatureScript.appendData(redeemScriptData)
                                    }
                                } catch _ as NSError {
                                    //验证不通过，还需要继续签名
                                    isComplete = false
                                    //删除最后的赎回脚本，等到新签名添加上才继续
                                }
                                
                            }
                        }
                        
                        if isComplete {
                            //如果是单签，直接可以签名发送
                            completionHandler(tx, nil, nil, MessageModule(code: "0", message: "Success".localized()));
                        } else {
                            //如果是多签，需要发送交易单给地址生产的公钥持有者进行私钥签名
                            completionHandler(tx, txHex, singnatureHex, MessageModule(code: "1101", message: "need other signatures".localized()));
                        }
                        
                    }
                } else {
                    completionHandler(nil, nil, nil, MessageModule(code: "1001", message: "Balance not enough".localized()))
                }
            }
            
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

// MARK: - 文本输入代理
extension BTCSendViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.setupFee()
    }
    
}


// MARK: - 扫描地址二维码
extension BTCSendViewController: AddressScanViewDelegate {
    
    func didScanQRCodeSuccess(vc: AddressScanViewController, result: String) {
        self.labelAddress.textColor = UIColor.darkGray
        self.labelAddress.text = result
        self.address = result
    }
}
