//
//  SendViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/26.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class BTCSendViewController: BaseTableViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var buttonConfirm: CHButton!
    @IBOutlet var labelTextAvailable: CHLabelTextField!
    @IBOutlet var labelTextAddress: CHLabelTextField!
    @IBOutlet var labelTextFees: CHLabelTextField!
    @IBOutlet var labelTextActualTotal: CHLabelTextField!
    @IBOutlet var labelTextAmount: CHLabelTextField!
    
    var currencyType = CurrencyType.BTC
    var addressNote = ""
    
    //手续列表，暂时满足日常，以后将会有更高级设置
    var feesArray: [BTCAmount] {
        return [
            BTCAmount(10000),
            BTCAmount(30000),
            BTCAmount(50000),
            BTCAmount(70000),
            BTCAmount(100000),
            BTCAmount(150000),
            BTCAmount(200000),
            BTCAmount(300000),
        ]
    }
    
    //已选手续费
    lazy var selectedFees: BTCAmount = self.feesArray[1]
    
    var address = ""
    var actualTotal: BTCAmount!
    var availableTotal: BTCAmount {
        guard let ub = self.btcAccount.userBalance else {
            return 0
        }
        let balance = BTCAmount(ub.balanceSat + ub.unconfirmedBalanceSat)
        return balance
    }
    
    
    var btcAccount: CHBTCAcount!
    var changeAddress: BTCAddress {
        return self.btcAccount.address
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        //加载余额缓存
        self.btcAccount.loadUserBalanceCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.labelTextAvailable.text = self.availableTotal.toBTC()

        self.setupActualTotal()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.cellAddRoundStyle(tableView: tableView,
                               indexPath: indexPath,
                               bgImages: [
                                UIImage(named:"bg_round_cell")!,
                                UIImage(named:"bg_round_cell_up")!,
                                UIImage(named:"bg_round_cell_down")!,
                                UIImage(named:"bg_round_cell_mid")!,
                                ],
                               sidePadding: 8.0)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}

// MARK: - 控制器方法
extension BTCSendViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        self.navigationItem.title = "Send".localized() + currencyType.rawValue
        
        self.labelTextAvailable.title = "Available".localized() + "(\(self.currencyType.rawValue))"
        self.labelTextAvailable.placeholder = "Total Avaliable Balance".localized()
        self.labelTextAvailable.delegate = self
        self.labelTextAddress.title = "Receiver Address".localized()
        self.labelTextAddress.placeholder = "e.g: bitcoin:1abcdefg.. or 1abcdefg...".localized()
        self.labelTextAddress.delegate = self
        self.labelTextAmount.title = "Transfer Amount".localized() + "(\(self.currencyType.rawValue))"
        self.labelTextAmount.placeholder = "Amount of ".localized() + "\(self.currencyType.rawValue)"
        self.labelTextAmount.delegate = self
        self.labelTextFees.title = "Fees".localized() + "(\(self.currencyType.rawValue))"
        self.labelTextFees.text = self.selectedFees.toBTC()
        self.labelTextFees.delegate = self
        self.labelTextActualTotal.title = "Actual Total".localized() + "(\(self.currencyType.rawValue))"
        self.labelTextActualTotal.delegate = self
        self.labelTextAmount.textField?.keyboardType = .decimalPad
        
        self.buttonConfirm.setTitle("Send".localized(), for: .normal)
        
        self.labelTextAmount.textField?.addDoneOnKeyboardWithTarget(self, action: #selector(self.keyboardDoneAction))
        
        //点击地址文本复制
        self.labelTextAddress.textPress = {
            (lt) -> Void in
            self.handleAddressPress(nil)
        }
        
        self.labelTextAddress.accessoryPress = {
            (lt) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressScanViewController") as! AddressScanViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        self.labelTextFees.textPress = {
            (lt) -> Void in
            self.handleFeesPress()
        }
    }
    
    
    /// 关闭键盘
    ///
    /// - Parameter sender:
    func keyboardDoneAction() {
        AppDelegate.sharedInstance().closeKeyBoard()
    }
    
    //计算实际发送数量
    func setupActualTotal() {
        
        var amount = self.labelTextAmount.text.toBTCAmount()
        
        if amount >= self.availableTotal {
            //如果输入的转账数目大于当前余额，输入
            self.actualTotal = self.availableTotal
            //输入的数量改为”余额 - 矿工费“
            amount = self.availableTotal - self.selectedFees
            if amount > 0 {
                self.labelTextAmount.text = amount.toBTC()
            } else {
                self.labelTextAmount.text = ""
            }
            
        } else {
            self.actualTotal = amount  + self.selectedFees
        }
        
        
        self.labelTextActualTotal.text = self.actualTotal.toBTC()
        
    }
    
    /**
     点击地址
     
     - parameter sender:
    */
    @IBAction func handleAddressPress(_ sender: AnyObject?) {
        //收回键盘
        self.keyboardDoneAction()
        
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
                var pasteAddress = pasteboard.string!
                //如果地址带bitcoin:头就把它替换为""
                if pasteAddress.hasPrefix(self.currencyType.addressPrefix) {
                    pasteAddress = pasteAddress.replacingOccurrences(of: self.currencyType.addressPrefix, with: "")
                }
                
                self.labelTextAddress.text = pasteAddress
                self.address = pasteAddress
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
    func gotoSendTransactionHexView(_ tx: BTCTransaction, unsignTxHex: String, singnatureHex: [String]) {
        guard let vc = StoryBoard.wallet.initView(type: BTCSendMultiSigViewController.self) else {
            SVProgressHUD.showError(withStatus: "Unknown error".localized())
            return
        }
        
        let index = self.btcAccount.index(of: self.btcAccount.redeemScript!)
        if index < 0 {
            SVProgressHUD.showError(withStatus: "Unknown error".localized())
            return
        }
        
        //封装一个多重签名交易表单
        let mtx = MultiSigTransaction(
            rawTx: unsignTxHex,
            keySignatures: [String(index) : singnatureHex],
            redeemScriptHex: self.btcAccount.redeemScript!.hex
        )
        
        vc.currentAccount = self.btcAccount
        vc.multiSigTx = mtx
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /**
     选择历史打币地址
     
     - parameter sender:
     */
    @IBAction func handleAddressMorePress(_ sender: AnyObject?) {
        
        //收回键盘
        self.keyboardDoneAction()
    }
    
    
    /**
     点击确认按钮
     
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
        self.keyboardDoneAction()
        if self.checkValue() {
            
            
            let doBlock = {
                () -> Void in
                SVProgressHUD.show(with: SVProgressHUDMaskType.black)
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
        
        if self.labelTextAmount.text.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Amount is empty".localized())
            return false
        }
        
        return true
    }
    
    /**
     获取未花的记录
     */
    func getUnspentTransactionByWebservice(
        _ completionHandler: @escaping (BTCTransaction?, String? , [String]?, MessageModule) -> Void) {
        let nodeServer = CHWalletWrapper.selectedBlockchainNode.service
        nodeServer.userUnspentTransactions(address: self.changeAddress.string) {
                (message, unspentTxs) -> Void in
                if unspentTxs.count > 0 {
                    
                    var isComplete = true
                    
                    //付币总数
                    let totalAmount = self.actualTotal!
                    
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
                        let paymentOutput = BTCTransactionOutput(value: totalAmount - self.selectedFees, address: destinationAddress)
                        
                        tx.addOutput(paymentOutput)
                        
                        if (spentCoins - totalAmount > 0) {
                            let changeOutput = BTCTransactionOutput(value: spentCoins - totalAmount, address: self.changeAddress)
                            tx.addOutput(changeOutput)
                        }
                        
                        //先导出未签名的交易hex，多签时要隔离验证
                        let txHex = tx.hex
                        //签名HEX多个Input
                        var singnatureHex = [String]()
                        
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
                                let inputSingnatureHex = (signature as NSData).hex()
                                singnatureHex.append(inputSingnatureHex!)
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
                            completionHandler(tx, nil, nil, MessageModule(code: ApiResultCode.Success.rawValue, message: "Success".localized()));
                        } else {
                            //如果是多签，需要发送交易单给地址生产的公钥持有者进行私钥签名
                            completionHandler(tx, txHex, singnatureHex, MessageModule(code: ApiResultCode.NeedOtherSignature.rawValue, message: "need other signatures".localized()));
                        }
                        
                    }
                } else {
                    completionHandler(nil, nil, nil, MessageModule(code: ApiResultCode.ErrorTips.rawValue, message: "Balance not enough".localized()))
                }
            }
            
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
    
    
    /// 选择矿工费
    func handleFeesPress() {
        
        //收回键盘
        self.keyboardDoneAction()
        
        let selectedIndex = self.feesArray.index(of: self.selectedFees)
        let feesSeletions = self.feesArray.map {$0.toBTC()}
        ActionSheetStringPicker.show(withTitle: "Choose Fees".localized(), rows: feesSeletions, initialSelection: selectedIndex!, doneBlock: { (picker, index, item) in
            self.selectedFees = self.feesArray[index]
            self.labelTextFees.text = self.selectedFees.toBTC()
            self.setupActualTotal()
        }, cancel: {
            (picker) in
            
        }, origin: self.tableView)
    }
}

// MARK: - 文本输入代理
extension BTCSendViewController: CHLabelTextFieldDelegate {
    
    func textFieldShouldReturn(_ ltf: CHLabelTextField) -> Bool {
        ltf.resignFirstResponder()
        return true
    }
    
//    func textFieldShouldEndEditing(_ ltf: CHLabelTextField) -> Bool {
//        return true
//    }
    
    func textFieldDidEndEditing(_ ltf: CHLabelTextField) {
        self.setupActualTotal()
    }
    
}


// MARK: - 扫描地址二维码
extension BTCSendViewController: AddressScanViewDelegate {
    
    func didScanQRCodeSuccess(vc: AddressScanViewController, result: String) {
        var pasteAddress = result
        //如果地址带bitcoin:头就把它替换为""
        if pasteAddress.hasPrefix(self.currencyType.addressPrefix) {
            pasteAddress = pasteAddress.replacingOccurrences(of: self.currencyType.addressPrefix, with: "")
        }
        
        self.labelTextAddress.text = pasteAddress
        self.address = pasteAddress
    }
}
