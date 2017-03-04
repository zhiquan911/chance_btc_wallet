//
//  ExportKeyViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/26.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class ExportKeyViewController: BaseViewController {

    /// MARK: - 成员变量
    @IBOutlet var imageViewQRCode: UIImageView!
    @IBOutlet var buttonAddress: UIButton!
    
    var address: String {
        if keyType == .PrivateKey {
            return self.currentAccount.extendedPrivateKey
        } else if keyType == .PublicKey {
            Log.debug("extendedPublicKey = \(currentAccount.extendedPublicKey)")
            Log.debug("publicKey = \(BTCBase58StringWithData(currentAccount.privateKey!.compressedPublicKey as Data!))")
            return currentAccount.extendedPublicKey
        } else if keyType == .RedeemScript {
            let redeemScript = currentAccount.redeemScript!
            return redeemScript.hex
        } else {
            return ""
        }
    }
    
    var keyType = ExportKeyType.PrivateKey
    
    var currentAccount: CHBTCAcount!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonAddress.setTitle(self.address, for: UIControlState())
        self.imageViewQRCode.image = QRCode.generateImage(self.address, avatarImage: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 控制器方法
extension ExportKeyViewController {
    
    
    @IBAction func handleAddressPress(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: "Share".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Copy".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.address
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            self.showShareMenuView(nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    /// 弹出分享选择菜单
    @IBAction func showShareMenuView(_ sender: AnyObject?) {
        let recevicedAddress = self.address
        let activityViewController = UIActivityViewController(activityItems: [recevicedAddress], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}
