//
//  UITableViewCell+extension.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/13.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func cellAddRoundStyle(tableView: UITableView, indexPath: IndexPath, bgImages: [UIImage], sidePadding: CGFloat = 0) {
        
        //table中section的总行数
        let numOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        
        let tag = 170313    //背景标识
        var bgImageView: UIImageView? = self.viewWithTag(tag) as? UIImageView
        if bgImageView == nil {
            bgImageView = UIImageView()
            bgImageView!.translatesAutoresizingMaskIntoConstraints = false
            bgImageView!.tag = 170313
            self.contentView.addSubview(bgImageView!)
            self.contentView.sendSubview(toBack: bgImageView!)
            
            let views: [String : Any] = [
                "bgImageView": bgImageView!
            ]
            
            self.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-\(sidePadding)-[bgImageView]-\(sidePadding)-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
            
            self.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[bgImageView]-0-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        }
        
        if indexPath.row == 0 && numOfRowsInSection == 1 {
            //只有一个，整个行都显示圆角
            bgImageView?.image = bgImages[0]
        } else if indexPath.row == 0 {
            //只显示上半部圆角
            bgImageView?.image = bgImages[1]
        } else if indexPath.row == numOfRowsInSection - 1 {
            //显示下半部圆角
            bgImageView?.image = bgImages[2]
        } else {
            //显示中间部分
            bgImageView?.image = bgImages[3]
        }
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
}
