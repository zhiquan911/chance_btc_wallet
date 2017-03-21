//
//  SettingCell.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/21.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var switchEnable: UISwitch!

    class var cellIdentifier: String{
        
        return "SettingCell"
    }
    
    typealias EnableChange =
        (_ cell: SettingCell, _ sender: UISwitch) -> Void
    var enableChange: EnableChange?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 开关切换
    ///
    /// - Parameter sender:
    @IBAction func handleSwitchEnableChange(sender: UISwitch) {
        
        self.enableChange?(self, sender)
    }

}
