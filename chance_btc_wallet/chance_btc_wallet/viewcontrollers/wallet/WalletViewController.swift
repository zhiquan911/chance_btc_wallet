//
//  WalletViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/19.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import Foundation

class WalletViewController: BaseViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var labelUserAccount: UILabel!
    @IBOutlet var viewUser: UIView!
    @IBOutlet var buttonSend: UIButton!
    @IBOutlet var buttonReceive: UIButton!
    @IBOutlet var tableViewTransactions: UITableView!
    @IBOutlet var tableViewUserMenu: UITableView!
    
    var dropdownView: LMDropdownView!
    var userName = ""
    var address = ""
    var balance: BTCAmount = 0
    var refreshTimer: Timer?              //刷新数据定时器
    var transactions = [UserTransaction]()
    var logining = false
    var currentAccount: CHBTCAcounts?           //当前账户
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        //注册一个通知用于更新钱包账户
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateUserWallet),
            name: NSNotification.Name(rawValue: "updateUserWallet"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //通知更新
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "updateUserWallet"),
            object: nil)
        
        if self.refreshTimer == nil {
            self.refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateUserWallet), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 控制器方法
extension WalletViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        
        //导航栏弹出下拉菜单的尺寸适应当前view的宽度
        self.tableViewUserMenu.frame = CGRect(x: 0, y: 0,
            width: self.view.bounds.width,
            height: min(self.view.bounds.height/2, 100))
        
    }
    
    
    /**
     点击导航栏上标题按钮
     
     - parameter sender:
     */
    @IBAction func handleNavTitleButtonPress(_ sender: AnyObject?) {
        self.tableViewUserMenu.reloadData()
        // Init dropdown view
        if self.dropdownView == nil {
            self.dropdownView = LMDropdownView()
            self.dropdownView.delegate = self;
            self.dropdownView.closedScale = 1;
            self.dropdownView.blurRadius = 5;
            self.dropdownView.blackMaskAlpha = 0.5;
            self.dropdownView.animationDuration = 0.5;
            self.dropdownView.animationBounceHeight = 20;
            self.dropdownView.contentBackgroundColor = UIColor(hex: 0x2E3F53)
        }
        
        if self.dropdownView.isOpen {
            self.dropdownView.hide()
        } else {
            self.dropdownView.show(
                from: self.navigationController, withContentView: self.tableViewUserMenu)
        }
    }
    
    /**
     更新账户
     
     - parameter obj:
     */
    func updateUserWallet() {
        let accounts = CHBTCWallets.sharedInstance.getAccounts()
        for account in accounts {
            if account.address.string == CHWalletWrapper.selectedAccount {
                self.currentAccount = account       //记录当前账户对象
                self.userName = account.userNickname
                self.address = account.address.string
                
                self.labelUserName.text = self.userName
                //获取账户余额
                self.getUserAccountByWebservice()
                self.getUserTransactionsByWebservice()

                
            }
        }

        
    }
    
    /**
     调用获取账户接口
     */
    func getUserAccountByWebservice() {
        BlockchainRemoteService.sharedInstance.userBalance(address: self.address) {
            (message, userBalance) -> Void in
            if message.code == ApiResultCode.Success.rawValue {
                self.balance = Int64(userBalance.balanceSat) + Int64(userBalance.unconfirmedBalanceSat)
                self.labelUserAccount.text = "฿ \(BTCAmount.stringWithSatoshiInBTCFormat(self.balance))"
            }
            
        }
    }
    
    /**
     获取交易记录
     */
    func getUserTransactionsByWebservice() {
        
        BlockchainRemoteService.sharedInstance.userTransactions(
            address: self.address, from: "0", to: "", limit: "20") {
                (message, userTransactions, page) -> Void in
                if message.code == ApiResultCode.Success.rawValue {
                    self.transactions = userTransactions
                    self.tableViewTransactions.reloadData()
                }
        }
        
        /*
        InsightRemoteService.sharedInstance.userTransactions(
            self.address, from: "0", to: "20") {
                (message, userTransactions, page) -> Void in
                if message.code! == ApiResultCode.Success.rawValue {
                    self.transactions = userTransactions
                    self.tableViewTransactions.reloadData()
                }
        }
        */
    }
    
    /**
     点击收币
     
     - parameter sender:
     */
    @IBAction func handleReceivePress(_ sender: AnyObject?) {
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BTCReceiveViewController") as! BTCReceiveViewController
//        vc.address = self.address
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     点击付币
     
     - parameter sender:
     */
    @IBAction func handleSendPress(_ sender: AnyObject?) {
//        if BBKeyStore.sharedInstance.selectedAccountType == BKAccountType.Normal {
//            self.gotoBTCSendView()
//        } else {
            self.showMultiSigTransactionMenu()
//        }
    }
    
    /**
     弹出多重签名发送btc选择的菜单
     */
    func showMultiSigTransactionMenu() {
        let actionSheet = UIAlertController(title: "选择发送方式", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "创建新交易", style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.gotoBTCSendView()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "粘贴来至他人的交易", style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if pasteboard.string?.length ?? 0 > 0 {
                self.gotoMultiSigTransactionView(pasteboard.string!)
            } else {
                SVProgressHUD.showInfo(withStatus: "剪贴板没有内容")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /**
     进入交易信息再签名界面
     */
    func gotoMultiSigTransactionView(_ message: String) {
        
        let msgs = message.components(separatedBy: "&")
        if msgs.count == 3 {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BTCMultiSigTransactionViewController") as! BTCMultiSigTransactionViewController
//            
//            vc.transactionHex = msgs[0]
//            vc.multiSigHexs = msgs[1]
//            vc.redeemScriptHex = msgs[2]
//            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "解析交易信息出错")
        }

    }
    
    
    /**
     进入发送比特币界面
     */
    func gotoBTCSendView() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BTCSendViewController") as! BTCSendViewController
//        vc.availableTotal = self.balance
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     是否自己与自己交易
     
     - parameter tx:
     
     - returns:
     */
    func isTransactionToSelf(_ tx: UserTransaction) -> Bool {
        //输出输入的所有地址
        var addresses = [String]()
        for txunit in tx.vinTxs {
            addresses.append(txunit.address)
        }
        
        for txunit in tx.voutTxs {
            addresses.append(txunit.address)
        }
        
        //清除所有与自己相同的元素，如果数组为0则，这个交易是发给自己的
        let filteredAddresses = self.filteredAddresses(addresses)
        if filteredAddresses.0.count == 0 {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     过滤重复的地址
     
     - parameter addresses:
     
     - returns: 不重复的地址，所有地址合成成一个字符串
     */
    func filteredAddresses(_ addresses: [String]) -> ([String], String) {
        //清除重复地址
        var filteredAddresses = Array(Set(addresses))
        
        let indexForCurrentUser = filteredAddresses.index(of: self.address)
        if indexForCurrentUser != nil && indexForCurrentUser != NSNotFound {
            filteredAddresses.remove(at: indexForCurrentUser!)
        }
        
        let addressString = NSMutableString()
        
        for (i, address) in filteredAddresses.enumerated() {
            
            // Truncate if we have more then one.
            if filteredAddresses.count > 1 {
                let shortenedAddress = address.substring(to: address.characters.index(address.startIndex, offsetBy: 10))
                addressString.append("\(shortenedAddress)…")
            } else {
                addressString.append(address)
            }
            
            // Add a comma and space if this is not the last
            if (i != filteredAddresses.count - 1) {
                addressString.append(", ")
            }
        }
        
        return (filteredAddresses, String(addressString))
    }
    
    /**
     拼接发送或接收的地址
     
     - parameter txs:
     
     - returns:
     */
    func addressesString(_ txs: [TransactionUnit]) -> String {
        var addresses = [String]()
        for tx in txs {
            addresses.append(tx.address)
        }
        return self.filteredAddresses(addresses).1
    }
    
    /**
     统计输入输出的交易记录总数
     
     - parameter tx:
     
     - returns:
     */
    func valueForIOPut(_ tx: TransactionUnit) -> BTCAmount {
        var amount: BTCAmount = 0;
        let address = tx.address
        var isForUserAddress = false;
        if (address == self.address) {
            isForUserAddress = true;
        }
        if (isForUserAddress) {
            amount = amount + tx.value
        }
        return amount;
    }
    
    /**
     统计单个用户单个交易的资金变动
     
     - parameter tx:
     
     - returns:
     */
    func valueForTransactionForCurrentUser(_ tx: UserTransaction) -> BTCAmount {
        var valueForWallet: BTCAmount = 0;
        if  self.isTransactionToSelf(tx) {
            //第一个输出就是全部的资金变动
            valueForWallet = tx.voutTxs[0].value
        } else {
            //计算发送的总金额
            var amountSent: BTCAmount = 0;
            for input in tx.vinTxs {
                amountSent = amountSent + self.valueForIOPut(input)
            }
            
            //计算接收的总金额
            var amountReceived: BTCAmount = 0;
            for output in tx.voutTxs {
                amountReceived = amountReceived + self.valueForIOPut(output)
            }
            
            valueForWallet = amountReceived - amountSent;
            // If it is sent, do not include fee.
            if (valueForWallet < 0) {
                let fee = BTCAmount(tx.fees * Double(BTCCoin))
                valueForWallet = valueForWallet + fee
            }
        }
        
        return valueForWallet
    }
    
    /**
     进入创建多签账户界面
     */
    func gotoCreateMultiSigView() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MultiSigAccountCreateViewController") as! MultiSigAccountCreateViewController
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 实现导航栏弹出下拉菜单功能
extension WalletViewController: LMDropdownViewDelegate {
    
    func dropdownViewWillShow(_ dropdownView: LMDropdownView!) {
        self.tabBarController?.tabBar.isUserInteractionEnabled = false;
    }
    
    func dropdownViewDidHide(_ dropdownView: LMDropdownView!) {
        self.tabBarController?.tabBar.isUserInteractionEnabled = true;
        
    }
}

// MARK: - 表格代理方法
extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === self.tableViewUserMenu {
            return 1
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableViewUserMenu {
            let accounts = CHBTCWallets.sharedInstance.getAccounts()
            return accounts.count + 1
        } else {
            return self.transactions.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === self.tableViewUserMenu {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
            
            cell.imageViewSelected.isHidden = true
            
            let accounts = CHBTCWallets.sharedInstance.getAccounts()
            if indexPath.row == accounts.count { //最后一行显示添加账户
                cell.labelMenuTitle.text = "Create new account".localized() //创建新账户
                cell.labelAddress.text = ""
            } else {
                
                let btcAccount = CHBTCWallets.sharedInstance.getAccount(indexPath.row)!
                if self.userName == btcAccount.userNickname {
                    cell.imageViewSelected.isHidden = false
                } else {
                    cell.imageViewSelected.isHidden = true
                }
                
                cell.labelMenuTitle.text = btcAccount.userNickname
                cell.labelAddress.text = btcAccount.address.string
            }

            
            return cell
            
        } else {
            let cell: UserTransactionCell
            cell = tableView.dequeueReusableCell(withIdentifier: "UserTransactionCell") as! UserTransactionCell
            let tx = self.transactions[indexPath.row]
            
            //交易确认事件
            let localDateString = Date.getShortTimeByStamp(Int64(tx.blocktime))
            
            if (tx.confirmations == 0) {
                cell.labelTime.text = "unconfirmed";
            } else {
                cell.labelTime.text = localDateString;
            }
            //交易的数量
            let transactionValue = self.valueForTransactionForCurrentUser(tx)
            let transactionAmountString = "฿ \(BTCAmount.stringWithSatoshiInBTCFormat(transactionValue))"
            cell.labelChange.text = transactionAmountString;
            
            // Change Color of Transaction Amount if is sent or received or to self
            let isTransactionToSelf = self.isTransactionToSelf(tx)
            if (isTransactionToSelf) {
                cell.labelChange.textColor =  UIColor(hex: 0x7d2b8b)
                cell.labelChange.text = "To: me";
            } else {
                if (transactionValue < 0) {
                    //发送
                    cell.labelChange.textColor =  UIColor(hex: 0xf76b6b)
                    cell.labelAddress.text = "To: \(self.addressesString(tx.voutTxs))"
                } else {
                    // 接收
                    cell.labelChange.textColor =  UIColor(hex: 0x7fdf40)
                    cell.labelAddress.text = "From: \(self.addressesString(tx.vinTxs))"
                }
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.tableViewUserMenu {
            return 50
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView === self.tableViewUserMenu {
            
            let accounts = CHBTCWallets.sharedInstance.getAccounts()
            if indexPath.row == accounts.count { //最后一行显示添加账户
                self.gotoCreateMultiSigView() //创建新账户
            } else {
                
                let btcAccount = CHBTCWallets.sharedInstance.getAccount(indexPath.row)!
                self.currentAccount = btcAccount       //记录当前账户对象
                self.userName = btcAccount.userNickname
                self.address = btcAccount.address.string
                
                self.labelUserName.text = self.userName
            }
            
            //通知更新
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "updateUserWallet"),
                object: nil)
            
            self.dropdownView.hide()
            
        }
    }
    
}
