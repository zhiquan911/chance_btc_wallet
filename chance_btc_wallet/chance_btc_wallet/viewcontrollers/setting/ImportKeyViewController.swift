//
//  ImportKeyViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/29.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class ImportKeyViewController: BaseViewController {
    
    @IBOutlet var labelWarning: UILabel!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var buttonImport: UIButton!
    @IBOutlet var buttonConfirm: UIButton!

    var alertView: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
/*
// MARK: - 控制器方法
extension ImportKeyViewController {
    /**
     配置UI
     */
    func setupUI() {
        
        //按钮圆角
        self.buttonConfirm.layer.cornerRadius = 3
        self.buttonConfirm.layer.masksToBounds = true
        self.buttonConfirm.setBackgroundImage(
            UIColor.imageWithColor(UIColor(hex: 0xE10B17)),
            for: UIControlState())

        self.buttonImport.layer.cornerRadius = 3
        self.buttonImport.layer.masksToBounds = true
        self.buttonImport.setBackgroundImage(
            UIColor.imageWithColor(UIColor(hex: 0xE10B17)),
            for: UIControlState())
    }
    
    /**
     选择导入私钥方式
     
     - parameter sender: 
     */
    @IBAction func handleImportPress(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: "选择方式", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "扫描二维码", style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressScanViewController") as! AddressScanViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "从剪贴板粘贴", style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            if pasteboard.string?.length > 0 {
                self.labelInfo.text = pasteboard.string!
                
                self.buttonConfirm.isHidden = false
                self.buttonImport.isHidden = true
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
     确认导入
     
     - parameter sender:
     */
    @IBAction func handleConfirmPress(_ sender: AnyObject?) {
        //检查账户是否有未花余额
        var address = BBKeyStore.sharedInstance.publicKey.address.string
        self.getUserAccountByWebservice(address) {
            (message) -> Void in
            if message.code! == ApiResultCode.Success.rawValue {
                //检查多签的地址是否有未花余额
                if BBKeyStore.sharedInstance.multiSigAddress != nil {
                    address = BBKeyStore.sharedInstance.multiSigAddress!.string
                    self.getUserAccountByWebservice(address, complete: {
                        (message2) -> Void in
                        if message.code! == ApiResultCode.Success.rawValue {
                            self.resetPrivateKey()
                        }
                    })
                } else {
                    self.resetPrivateKey()
                }
                
            } else {
                SVProgressHUD.showError(withStatus: message.message)
            }
        }
    }
    
    /**
     重置私钥
     */
    func resetPrivateKey() {
        
        self.alertView = STAlertView(title: "创建账户", message: "", textFieldHint: "输入您的账户名称", textFieldValue: nil, cancelButtonTitle: "取消", otherButtonTitle: "完成", cancelButtonBlock: nil, otherButtonBlock: {
            (result) -> Void in
            if result?.length > 0 {
                
                BBKeyStore.sharedInstance.key = BTCKey(wif: self.labelInfo.text)
                BBKeyStore.sharedInstance.selectedAccountType = BKAccountType.Normal
                
                //清除多签的地址和账户
                BBKeyStore.sharedInstance.deleteMultiSig()
                
                SVProgressHUD.showSuccess(withStatus: "导入私钥成功")
                self.navigationController?.popViewController(animated: true)
                
            } else {
                SVProgressHUD.showError(withStatus: "必须输入一个用户名")
            }
        })

        self.alertView!.show()
 
    }
    
    
    /**
     调用获取账户接口
     */
    func getUserAccountByWebservice(_ address: String,
        complete: ((MessageModule) -> Void)?) {
        SVProgressHUD.show(with: SVProgressHUDMaskType.black)
        InsightRemoteService.sharedInstance.userBalance(address) {
            (message, userBalance) -> Void in
            if message.code! == ApiResultCode.Success.rawValue {
                let balance = Int64(userBalance.balanceSat) + Int64(userBalance.unconfirmedBalanceSat)
                if balance > 0 {
                    message.code = "1001"
                    message.message = "地址：\(address)还有余额未花"
                    complete?(message)
                } else {
                    complete?(message)
                }
            } else {
                SVProgressHUD.showError(withStatus: message.message)
            }
            
        }
    }
    
}

// MARK: - 扫描地址二维码
extension ImportKeyViewController: AddressScanViewDelegate {
    
    func didScanQRCodeSuccess(_ vc: AddressScanViewController, result: String) {
        self.labelInfo.text = result
        self.buttonConfirm.isHidden = false
        self.buttonImport.isHidden = true
    }
}
*/
