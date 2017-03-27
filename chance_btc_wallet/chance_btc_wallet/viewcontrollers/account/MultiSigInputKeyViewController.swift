//
//  MultiSigInputKeyViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/27.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class MultiSigInputKeyViewController: BaseViewController {
    
    @IBOutlet var tableViewKeys: UITableView!
    @IBOutlet var buttonConfirm: UIButton!
    
    var keyCount: Int = 0
    var requiredCount: Int = 0
    var publicKeys = [String]()
    var selectedIndexPath: IndexPath?   //用于记录点击了那行的按钮
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.initEmptyData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

// MARK: - 控制器方法
extension MultiSigInputKeyViewController {
    
    /**
     配置UI
     */
    func setupUI() {
        self.navigationItem.title = "Get PublicKeys".localized()
        
    }
    
    /**
     初始化空数据
     
     - returns:
     */
    func initEmptyData() {
        for _ in 0..<(self.keyCount - 1) {
            self.publicKeys.append("")
        }
        
    }
    
    /**
     点击确认生成
     1.先创建一个新的HD账户
     2.使用这个HD账号公钥和其它公钥创建一个多重签名的账户
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
        AppDelegate.sharedInstance().closeKeyBoard()
        if self.checkValue() {
            
            //创建多重签名账户
            guard let account = CHBTCWallet.sharedInstance.createMSAccount(by: self.userName, otherPubkeys: self.publicKeys, required: requiredCount) else {
                SVProgressHUD.showError(withStatus: "Create Multi-Sig account failed".localized())
                return
            }
            
            CHBTCWallet.sharedInstance.selectedAccountIndex = account.index
            
            SVProgressHUD.showSuccess(withStatus: "Create Multi-Sig account successfully".localized())
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    /**
     检查值
     
     - returns:
     */
    func checkValue() -> Bool {
        
        //检查是否已经填满公钥
        for keystr in self.publicKeys {
            if keystr == "" {
                SVProgressHUD.showError(withStatus: "Please input a complete public key".localized())
                return false
            }
        }
        
        if self.publicKeys.count != keyCount - 1 {
            SVProgressHUD.showError(withStatus: "The amount of publickeys isn't enough".localized())
            return false
        }
        
        //检查公钥是否有重复
        let keysSet = Set(self.publicKeys)
        if keysSet.count != self.publicKeys.count {
            SVProgressHUD.showError(withStatus: "Duplicate publickeys".localized())
            return false
        }
        
        return true
    }
    
    /**
     扫描二维码
     */
    func scanQRCode() {
        //self.selectedIndexPath = indexPath
        guard let vc = StoryBoard.wallet.initView(type: AddressScanViewController.self) else {
            return
        }
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     点击公钥文本
    */
    func cellTextPress() {
        
        guard let indexPath = self.selectedIndexPath else {
            return
        }
        
        let actionSheet = UIAlertController(title: "Input publickey".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Scan QRCode".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.scanQRCode()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Paste from Clipboard".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if (pasteboard.string?.length ?? 0) > 0 {
                let row = indexPath.row - 1
                self.publicKeys[row] = pasteboard.string!
                
                self.tableViewKeys.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            } else {
                SVProgressHUD.showInfo(withStatus: "Clipboard is empty".localized())
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
 
    
    /// 处理粘贴公钥
    ///
    /// - Parameter sender:
    func handlePaste() {
        let pasteboard = UIPasteboard.general
        if (pasteboard.string?.length ?? 0) > 0 {
            
            guard let indexPath = self.selectedIndexPath else {
                return
            }
            
            let row = indexPath.row - 1
            self.publicKeys[row] = pasteboard.string!
            
            self.tableViewKeys.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            
        } else {
            SVProgressHUD.showInfo(withStatus: "Clipboard is empty".localized())
        }
    }
}


// MARK: - 表格代理方法
extension MultiSigInputKeyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keyCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyHeaderCell") as! CHPublicKeyHeaderCell
            cell.labelTips.text = "The Multi-Sig account that you are creating now has include you key. You just need to input  other external keys that you required.".localized()
            return cell
        } else if indexPath.row == numOfRowsInSection - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyFooterCell") as! CHPublicKeyFooterCell
            cell.buttonConfirm.setTitle("Create".localized(), for: .normal)
            
            cell.confirmPress = {
                (pressCell) -> Void in
                self.handleConfirmPress(nil)
            }
            
            return cell
            
        } else {
            let row = indexPath.row - 1
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyCell") as! CHPublicKeyCell
            
            cell.labelTextPublickey.title = "Paste or scan other publickeys".localized()
            cell.labelTextPublickey.placeholder = "e.g: xpub6CGxnmthv...8m3JWTJ".localized()
            cell.labelTextPublickey.isEditable = false
//            cell.labelTextPublickey.delegate = self
            
            let publickey = self.publicKeys[row]
            if publickey != "" {
                cell.labelTextPublickey.text = publickey
            } else {
                cell.labelTextPublickey.text = ""
            }
            
            
            cell.labelTextPublickey.accessoryPress = {
                (lt) -> Void in
                self.selectedIndexPath = tableView.indexPath(for: cell)
                self.scanQRCode()
            }
            
            cell.labelTextPublickey.textPress = {
                (lt) -> Void in
                self.selectedIndexPath = tableView.indexPath(for: cell)
                self.cellTextPress()
//                let pasteItem = UIMenuItem(title: "Paste".localized(), action: #selector(self.handlePaste))
//                lt.buttonForText?.showUIMenu(items: [pasteItem], containerView: self.view)
            }
            
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == 0 {
            return 90
        } else if indexPath.row == numOfRowsInSection - 1 {
            return 85
        } else {
            return 68
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
}


// MARK: - 扫描地址二维码
extension MultiSigInputKeyViewController: AddressScanViewDelegate {
    
    func didScanQRCodeSuccess(vc: AddressScanViewController, result: String) {
        
        guard let indexPath = self.selectedIndexPath else {
            return
        }
        
        let row = indexPath.row - 1
        self.publicKeys[row] = result
        self.tableViewKeys.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
}

