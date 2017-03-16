//
//  WalletCreateModeCellTableViewCell.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/7.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class WalletCreateModeCell: UITableViewCell {
    
    //MARK: - 成员变量
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelAbstract: UILabel!
    @IBOutlet var imageViewMode: UIImageView!

    
    class var cellIdentifier: String{
        
        return "WalletCreateModeCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
