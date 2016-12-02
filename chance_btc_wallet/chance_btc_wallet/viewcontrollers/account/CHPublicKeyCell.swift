//
//  PublicKeyCell.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/27.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class CHPublicKeyCell: UITableViewCell {
    
    @IBOutlet var labelPublickey: UILabel!
    @IBOutlet var buttonScan: UIButton!
    
    typealias ScanBlock = (CHPublicKeyCell) -> Void
    typealias TextPressBlock = (CHPublicKeyCell) -> Void
    var scanBlock: ScanBlock?
    var textPressBlock: TextPressBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(CHPublicKeyCell.handleTextPress(_:)))
        self.labelPublickey.addGestureRecognizer(tapGes)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleScanPress(_ sender: AnyObject?) {
        self.scanBlock?(self)
    }
    
    @IBAction func handleTextPress(_ sender: AnyObject?) {
        self.textPressBlock?(self)
    }

}
