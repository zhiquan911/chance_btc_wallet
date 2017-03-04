//
//  BTCAddressScanViewController.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

protocol AddressScanViewDelegate {
    
    /**
     扫描二维码成功
     
     - parameter vc:
     - parameter result:
     */
    func didScanQRCodeSuccess(vc: AddressScanViewController, result: String)
}

class AddressScanViewController: UIViewController {
    
    /// MARK: - 成员变量
    @IBOutlet var buttonClose: UIButton!
    @IBOutlet var labelTips: UILabel!
    var delegate: AddressScanViewDelegate?
    var tips = "Scan Address QRCode".localized()
    let scanner = QRCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTips.text = tips
        scanner.prepareScan(view) {
            (result) -> () in
            self.delegate?.didScanQRCodeSuccess(vc: self, result: result)
            self.dismiss(animated: true, completion: nil)
        }
        // test scan frame
        scanner.scanFrame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scanner.startScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleClosePress(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
