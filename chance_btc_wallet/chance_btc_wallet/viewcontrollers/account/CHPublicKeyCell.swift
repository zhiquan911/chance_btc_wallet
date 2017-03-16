//
//  PublicKeyCell.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/27.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class CHPublicKeyCell: UITableViewCell {
    
    @IBOutlet var labelTextPublickey: CHLabelTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class CHPublicKeyHeaderCell: UITableViewCell {
    
    @IBOutlet var labelTips: UILabel!
    
}

class CHPublicKeyFooterCell: UITableViewCell {
    
    @IBOutlet var buttonConfirm: UIButton!
    
    
    /// 点击确认按钮
    public typealias ConfirmPress = (CHPublicKeyFooterCell) -> Void
    public var confirmPress: ConfirmPress?
    
    /// 点击功能力按钮
    public func handleConfirmPress(sender: AnyObject?) {
        self.confirmPress?(self)
    }
}
