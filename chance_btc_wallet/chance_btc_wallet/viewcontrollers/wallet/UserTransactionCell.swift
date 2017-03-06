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

class UserTransactionSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var labelTxNum: UILabel!
    @IBOutlet var labelTxNumTitle: UILabel!
    
    @IBOutlet var labelTotalReceived: UILabel!
    @IBOutlet var labelTotalReceivedTitle: UILabel!
    
    
    class var cellIdentifier: String{
        
        return "UserTransactionSectionHeader"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = UIColor(hex: 0xF1F2F7)
        
        self.labelTxNumTitle.text = "Transactions：".localized()
        self.labelTotalReceivedTitle.text = "Total Received：".localized()
    }
    

    
    
    func configSectionHeader(account: CHBTCAcount?,
                             currencyType: CurrencyType,
                             exCurrencyType: CurrencyType) {
        
        if let ub = account?.userBalance {
            self.labelTotalReceived.text = "\(BTCAmount.stringWithSatoshiInBTCFormat(BTCAmount(ub.totalReceivedSat))) \(currencyType.rawValue)"
            self.labelTxNum.text = "\(ub.txApperances)"
        }
    }
}
