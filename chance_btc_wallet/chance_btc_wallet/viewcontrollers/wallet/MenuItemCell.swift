//
//  MenuItemCell.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/25.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet var labelMenuTitle: UILabel!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var imageViewSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
