//
//  ReceiveViewController.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/21.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import SwiftQRCode

class BTCReceiveViewController: BaseViewController {

    /// MARK: - 成员变量
    @IBOutlet var imageViewQRCode: UIImageView!
    @IBOutlet var buttonAddress: UIButton!
    
    var address: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BTC Address".localized()
        self.buttonAddress.setTitle(self.address, for: UIControlState())
        self.imageViewQRCode.image = QRCode.generateImage(self.address, avatarImage: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - 控制器方法
extension BTCReceiveViewController {
 
    
    @IBAction func handleAddressPress(_ sender: AnyObject?) {
        let actionSheet = UIAlertController(title: "Share".localized(), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Copy".localized(), style: UIAlertActionStyle.default, handler: {
            (action) -> Void in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.address
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
