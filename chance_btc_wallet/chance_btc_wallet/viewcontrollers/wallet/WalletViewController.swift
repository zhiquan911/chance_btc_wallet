//
//  WalletViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import Foundation
import CHPageCardView
import ESPullToRefresh

class WalletViewController: BaseViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var labelUserAccount: UILabel!
    @IBOutlet var viewUser: UIView!
    @IBOutlet var buttonSend: UIButton!
    @IBOutlet var buttonReceive: UIButton!
    @IBOutlet var tableViewTransactions: UITableView!
//    @IBOutlet var tableViewUserMenu: UITableView!
    @IBOutlet var pageCardView: CHPageCardView!
    
    let kHeightOfUserMenuCell: CGFloat = 50       //选择账户的高度
    
//    var dropdownView: LMDropdownView!
    var userName = ""
    var address = ""
//    var balance: BTCAmount = 0
    var userBalance: UserBalance?
    var refreshTimer: Timer?              //刷新数据定时器
    var transactions = [UserTransaction]()
    var logining = false
    var currentAccount: CHBTCAcount?           //当前账户
    var walletAccounts: [CHBTCAcount] = [CHBTCAcount]()
    var currencyType = CurrencyType.BTC
    var exCurrencyType = CurrencyType.USD
    
    var page = PageModule()
    
    var updateWalletTask: Task? //更新的异步任务
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //【1】配置一些UI属性
        self.setupUI()
        
        
        //【2】注册一个通知用于全局更新钱包账户列表
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadAllWalletAcount),
            name: NSNotification.Name(rawValue: "reloadAllWalletAcount"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏系统导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //创建刷新定时器，获取最新的交易记录
//        if self.refreshTimer == nil {
//            self.refreshTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateUserWallet), userInfo: nil, repeats: true)
//        }
        
        //【1】刷新钱包用户列表，可能有新增修改
        self.reloadAllWalletAcount()
        
        //【2】下拉刷新，获取最新的余额和交易记录
        self.tableViewTransactions.es_autoPullToRefresh()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        //隐藏系统导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
        //停止定时器
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
    
    //MARK: ios7状态栏修改
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
}

// MARK: - 控制器方法
extension WalletViewController {
    
    /**
     配置UI
     */
    func setupUI() {

        self.pageCardView.delegate = self
        self.pageCardView.register(nib:
            UINib(nibName: AccountCardPageCell.cellIdentifier, bundle: nil),
                                   forCellWithReuseIdentifier: AccountCardPageCell.cellIdentifier)
        self.pageCardView.register(nib:
            UINib(nibName: AccountCreateCell.cellIdentifier, bundle: nil),
                                   forCellWithReuseIdentifier: AccountCreateCell.cellIdentifier)
        
        //默认取xib组件上设置的值，但也可以使用代码设置每个单元格的尺寸
        //self.pageCardView.fixCellSize = CGSize(width: 260, height: 170)
        
        //使用固定的内间距控制单元格的大小，这样可以做到不同手机尺寸自动约束布局
        self.pageCardView.fixPadding = UIEdgeInsets(top: 26, left: 24, bottom: 26, right: 24)
        
        //清除空白表格
        self.tableViewTransactions.extraCellLineHidden()
        
        /// 添加下拉刷新组件
        self.addPullRefreshComponent()
    }
    
    
    /// 添加下拉刷新组件
    func addPullRefreshComponent() {
        
        self.tableViewTransactions.es_addPullToRefresh {
            [weak self] in
            self?.refresh()
        }
        self.tableViewTransactions.es_addInfiniteScrolling {
            [weak self] in
            self?.loadMore()
        }
        
        self.tableViewTransactions.refreshIdentifier = "Wallet"
        self.tableViewTransactions.expriedTimeInterval = 60.0
        
    }
    
    
    /**
     点击导航栏上标题按钮
     
     - parameter sender:
 
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
     */
    
    //刷新全部钱包数据
    func reloadAllWalletAcount() {
        
        //保证钱包是存在
        guard CHBTCWallet.checkBTCWalletExist() else {
            return
        }
        
        //刷新用户列表
        self.walletAccounts = CHBTCWallet.sharedInstance.getAccounts()
        self.pageCardView.reloadData()
        
        //在全部视图完成显示后，可以手动执行切换
        let selectedIndex = CHBTCWallet.sharedInstance.selectedAccountIndex
        if selectedIndex >= 0 {
            self.pageCardView.scroll(toIndex: selectedIndex, animated: false)
        }
        
        //更新当前选中用户的信息
        self.updateUserWallet(account: self.walletAccounts[selectedIndex])
    }
    
    /**
     更新账户
     
     - parameter obj:
     */
    func updateUserWallet(account: CHBTCAcount) {
        
        //保证钱包是存在
        guard CHBTCWallet.checkBTCWalletExist() else {
            return
        }
        
        self.userName = account.userNickname
        self.address = account.address.string
        self.currentAccount = account       //记录当前账户对象
        CHBTCWallet.sharedInstance.selectedAccountIndex = account.index //记录系统保存的选中用户
        
        
    }
    
    /**
     调用获取账户接口
     */
    func getUserAccountByWebservice() {
        let nodeServer = CHWalletWrapper.selectedBlockchainNode.service
        nodeServer.userBalance(address: self.address) {
            (message, userBalance) -> Void in
            if message.code == ApiResultCode.Success.rawValue {
//                self.balance = Int64(userBalance.balanceSat) + Int64(userBalance.unconfirmedBalanceSat)
                self.userBalance = userBalance
            }
            
        }
    }
    
    /**
     获取交易记录
     */
    func getUserTransactionsByWebservice(_ isRefresh: Bool,
                                         completeHandler:@escaping (_ dataCount: Int) -> Void) {
        let limit = self.page.pageSize
        let from = self.page.pageIndex * self.page.pageSize
        let to = from + limit
        let nodeServer = CHWalletWrapper.selectedBlockchainNode.service
        nodeServer.userTransactions(
        address: self.address, from: from.toString(), to: to.toString(), limit: limit.toString()) {
            (message, userBalance, userTransactions, page) -> Void in
            if message.code == ApiResultCode.Success.rawValue {
                
                //因为异步加载，可能会出现如果最后返回的账户不是本地选中的，就不更新数据
                
                //更新余额
                if userBalance != nil && userBalance!.address == self.address {
                    self.userBalance = userBalance
                    self.currentAccount?.userBalance = userBalance
                    //更新卡片余额
                    let selectedIndex = CHBTCWallet.sharedInstance.selectedAccountIndex
                    self.pageCardView.reloadItems(at: selectedIndex, animated: false)
                    
                    if (isRefresh) {
                        //清空数组
                        
                        self.transactions.removeAll()
                    }
                    self.transactions.append(contentsOf: userTransactions)
                    self.tableViewTransactions.reloadData()
                }
                
                
                
            }
            completeHandler(userTransactions.count)
        }
    
    }
    
    /**
     进入收币界面
     
     - parameter sender:
     */
    func gotoReceiveView() {
        
        guard let vc = StoryBoard.wallet.initView(type: BTCReceiveViewController.self) else {
            return
        }
        vc.address = self.address
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     点击付币
     
     - parameter sender:
 
    @IBAction func handleSendPress(_ sender: AnyObject?) {
        self.showMultiSigTransactionMenu()
    }
     */
    
    /**
     弹出多重签名发送btc选择的菜单
 
    func showMultiSigTransactionMenu() {
        let actionSheet = UIAlertController(title: "You can".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Send Bitcoin".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.gotoBTCSendView()
        }))
        
        //多重签名账户可以粘贴别人的签名交易
        actionSheet.addAction(UIAlertAction(title: "Paste from Clipboard".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if pasteboard.string?.length ?? 0 > 0 {
                self.gotoMultiSigTransactionView(pasteboard.string!)
            } else {
                SVProgressHUD.showInfo(withStatus: "Clipboard is empty".localized())
            }
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    */
    
    /**
     进入多重签名交易表单界面，进行签名
 
    func gotoMultiSigTransactionView(_ message: String) {
        
        //初始表单
        do {
            let mtx = try MultiSigTransaction(json: message)
            
            guard let vc = StoryBoard.wallet.initView(type: BTCMultiSigTransactionViewController.self) else {
                return
            }
            vc.currentAccount = self.currentAccount!
            vc.multiSigTx = mtx
            self.navigationController?.pushViewController(vc, animated: true)
            
        } catch {
            SVProgressHUD.showError(withStatus: "Transaction decode error".localized())
        }
        
    }
    */
    
    /**
     进入发送比特币界面
 
    func gotoBTCSendView() {
        guard let vc = StoryBoard.wallet.initView(type: BTCSendViewController.self) else {
            return
        }
        vc.btcAccount = self.currentAccount!
        var balance: BTCAmount = 0
        if self.userBalance != nil {
            balance = BTCAmount(self.userBalance!.balanceSat + self.userBalance!.unconfirmedBalanceSat)
        }
        vc.availableTotal = balance
        self.navigationController?.pushViewController(vc, animated: true)
    }
    */
    
    
    /**
     选择何种账户类型创建
     Normal Account：普通的HDM单签账户，由其私钥完全控制。
     Multi-Sig Account：多重签名合约账户，由联合的公钥组成的一个赎回脚本导出的地址。
     */
    func showCreateAccountTypeMenu() {
        let actionSheet = UIAlertController(title: "Create new account".localized(), message: "Which account type you need".localized(), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        /// 进入HDM账户创建界面
        actionSheet.addAction(UIAlertAction(title: "Normal Account".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.gotoCreateHDMAccount()
        }))
        
        //进入创建多签账户界面
        actionSheet.addAction(UIAlertAction(title: "Multi-Sig Account".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.gotoCreateMultiSigView()
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    /// 进入HDM账户创建界面
    func gotoCreateHDMAccount() {
        guard let vc = StoryBoard.account.initView(type: CreateHDMAccountViewController.self) else {
            return
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /// 进入创建多签账户界面
    func gotoCreateMultiSigView() {
        guard let vc = StoryBoard.account.initView(type: MultiSigAccountCreateViewController.self) else {
            return
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - 交易数据刷新与加载
extension WalletViewController {
    
    func refresh() {
        
        self.page.pageIndex = 0
        self.page.pageSize = 10
        
        self.getUserTransactionsByWebservice(true) {
            (dataCount) in
            self.tableViewTransactions.es_stopPullToRefresh()
            if dataCount < self.page.pageSize {
                self.tableViewTransactions.es_noticeNoMoreData()
            }
            if self.transactions.count == 0 {
                self.tableViewTransactions.es_footer?.isHidden = true
            } else {
                self.tableViewTransactions.es_footer?.isHidden = false
            }
            
        }
        
    }
    
    func loadMore() {
        
        //设置偏移量+kPageSize
        self.page.pageIndex = page.pageIndex + 1
        
        self.getUserTransactionsByWebservice(false) {
            (dataCount) in
            if dataCount < self.page.pageSize {
                self.tableViewTransactions.es_noticeNoMoreData()
            } else {
                self.tableViewTransactions.es_stopLoadingMore()
            }
        }
    }
}


// MARK: - 实现分页卡片组件委托方法
extension WalletViewController: CHPageCardViewDelegate {
    
    func numberOfCards(in pageCardView: CHPageCardView) -> Int {
        return self.walletAccounts.count + 1
    }
    
    func pageCardView(_ pageCardView: CHPageCardView, cellForIndexAt index: Int) -> UICollectionViewCell {
        
        if index == self.numberOfCards(in: pageCardView) - 1 {
            
            let cell = pageCardView.dequeueReusableCell(
                withReuseIdentifier: AccountCreateCell.cellIdentifier,
                for: index
                ) as! AccountCreateCell
            
            return cell
            
        } else {
            
            let cell = pageCardView.dequeueReusableCell(
                withReuseIdentifier: AccountCardPageCell.cellIdentifier,
                for: index
                ) as! AccountCardPageCell
            
            let btcAccount = self.walletAccounts[index]
            
            cell.configAccountCell(account: btcAccount,
                                   userBalance: self.userBalance,
                                   currencyType: self.currencyType,
                                   exCurrencyType: self.exCurrencyType)
            
            //配置控制器两个方法
            cell.addressPress = {
                (pressCell) -> Void in
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.currencyType.addressPrefix + btcAccount.address.string
                SVProgressHUD.showSuccess(withStatus: "Copied!".localized())
            }
            
            cell.qrCodePress = {
                (pressCell) -> Void in
                self.gotoReceiveView()
            }
            
            return cell
        }
    }
    
    func pageCardView(_ pageCardView: CHPageCardView, didSelectIndexAt index: Int) {
        
        if index == self.numberOfCards(in: pageCardView) - 1 {
            return
        }
        let btcAccount = self.walletAccounts[index]
        self.updateUserWallet(account: btcAccount)
        
        //切换后更新选中账户的余额和交易记录，先停了旧的任务
        self.cancel(self.updateWalletTask)
        self.tableViewTransactions.es_stopPullToRefresh()
        self.updateWalletTask = self.delay(1, task: {
            //刷新数据
            self.tableViewTransactions.es_startPullToRefresh()
        })
        
    }
}

// MARK: - 表格代理方法
extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    
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
                let decimalFee = tx.fees * NSDecimalNumber(value: BTCCoin)
                let fee = BTCAmount(decimalFee.int64Value)
                valueForWallet = valueForWallet + fee
            }
        }
        
        return valueForWallet
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.transactions.count
        tableView.tableViewDisplayWitMsg("No more transactions now".localized(), rowCount: count)
        return count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UserTransactionCell
        cell = tableView.dequeueReusableCell(withIdentifier: "UserTransactionCell") as! UserTransactionCell
        let tx = self.transactions[indexPath.row]
        
        //交易确认事件
        let localDateString = Date.getShortTimeByStamp(Int64(tx.blocktime))
        if (tx.confirmations == 0) {
            cell.labelTime.text = "unconfirmed".localized()
        } else {
            cell.labelTime.text = localDateString;
        }
        //交易的数量
        let transactionValue = self.valueForTransactionForCurrentUser(tx)
        let txType: TransactionInOut = transactionValue >= 0 ? .receive : .send
        let address = transactionValue >= 0 ? self.addressesString(tx.vinTxs) : self.addressesString(tx.voutTxs)
        let transactionAmountString = "\(txType.symbol)\(BTCAmount.stringWithSatoshiInBTCFormat(abs(transactionValue))) \(self.currencyType.rawValue)"
        cell.labelChange.text = transactionAmountString;
        
        // Change Color of Transaction Amount if is sent or received or to self
        let isTransactionToSelf = self.isTransactionToSelf(tx)
        if (isTransactionToSelf) {
            cell.labelChange.textColor =  UIColor(hex: 0x7d2b8b)
            cell.labelChange.text = "To：me".localized();
        } else {
            
            cell.imageViewIcon.image = txType.image
            cell.labelChange.textColor =  txType.color
            cell.labelAddress.text = txType.fromOrTo + "\(address)"

        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UserTransactionSectionHeader
        header = tableView.dequeueReusableCell(withIdentifier: "UserTransactionSectionHeader") as! UserTransactionSectionHeader
        if let ub = self.userBalance {
            header.labelTotalReceived.text = "\(BTCAmount.stringWithSatoshiInBTCFormat(BTCAmount(ub.totalReceivedSat))) \(self.currencyType.rawValue)"
            header.labelTxNum.text = "\(ub.txApperances)"
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        if tableView === self.tableViewUserMenu {
            
            let accounts = CHBTCWallet.sharedInstance.getAccounts()
            if indexPath.row == accounts.count { //最后一行显示添加账户
                self.showCreateAccountTypeMenu() //选择创建账户
            } else {
                
                let btcAccount = CHBTCWallet.sharedInstance.getAccount(by: indexPath.row)!
                self.currentAccount = btcAccount       //记录当前账户对象
                CHBTCWallet.sharedInstance.selectedAccountIndex = btcAccount.index //记录系统保存的选中用户
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
         */
    }
    
}
