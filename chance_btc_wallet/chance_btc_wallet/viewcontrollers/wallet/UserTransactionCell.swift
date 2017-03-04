//
//  UserTransactionCell.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/21.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class UserTransactionCell: UITableViewCell {
    
    @IBOutlet var labelChange: UILabel!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var imageViewIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class UserTransactionSectionHeader: UITableViewCell {
    
    @IBOutlet var labelTxNum: UILabel!
    @IBOutlet var labelTxNumTitle: UILabel!
    
    @IBOutlet var labelTotalReceived: UILabel!
    @IBOutlet var labelTotalReceivedTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelTxNumTitle.text = "Transactions：".localized()
        self.labelTotalReceivedTitle.text = "Total Received：".localized()
    }
    
}
