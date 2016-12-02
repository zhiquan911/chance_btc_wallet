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
    var selectedIndexPath: IndexPath?
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
        self.publicKeys.append("")
    }
    
    /**
     点击确认生成
     1.先创建一个新的HDM账户
     2.使用这个HDM账号公钥和其它公钥创建一个多重签名的账户
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
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
     
     - parameter indexPath:
     */
    func scanQRCode(_ indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        guard let vc = StoryBoard.wallet.initView(type: AddressScanViewController.self) else {
            return
        }
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     点击公钥文本
     
     - parameter indexPath:
     */
    func cellTextPress(_ indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        let actionSheet = UIAlertController(title: "Input publickey".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Scan QRCode".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.scanQRCode(indexPath)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Paste from Clipboard".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if (pasteboard.string?.length ?? 0) > 0 {
                self.publicKeys[indexPath.section] = pasteboard.string!
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
}


// MARK: - 表格代理方法
extension MultiSigInputKeyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.keyCount - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyCell") as! CHPublicKeyCell
        let publickey = self.publicKeys[indexPath.section]
        if publickey != "" {
            cell.labelPublickey.text = publickey
            cell.labelPublickey.textColor = UIColor.black
        } else {
            cell.labelPublickey.text = "Paste or scan other publickeys".localized()
            cell.labelPublickey.textColor = UIColor.lightGray
        }
        
        cell.scanBlock = {
            (selectCell) -> Void in
            let selectedIndexPath = tableView.indexPath(for: cell)
            self.scanQRCode(selectedIndexPath!)
        }
        
        cell.textPressBlock = {
            (selectCell) -> Void in
            let selectedIndexPath = tableView.indexPath(for: cell)
            self.cellTextPress(selectedIndexPath!)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}


// MARK: - 扫描地址二维码
extension MultiSigInputKeyViewController: AddressScanViewDelegate {
    
    func didScanQRCodeSuccess(vc: AddressScanViewController, result: String) {
        if selectedIndexPath != nil {
            self.publicKeys[selectedIndexPath!.section] = result
            self.tableViewKeys.reloadRows(at: [selectedIndexPath!], with: UITableViewRowAnimation.none)
        }
    }
}
