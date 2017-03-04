//
//  UITableView+extension.swift
//  Chance_wallet
//
//  Created by Chance on 15/12/10.
//  Copyright © 2015年 Chance. All rights reserved.
//

import Foundation

extension UITableView {
    
    
    /// 隐藏多余的空白行
    func extraCellLineHidden() {
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.tableFooterView = view
    }
    
    /**
     没有数据时显示提示
    */
    func tableViewDisplayWitMsg(_ message: String, rowCount: Int) {
        if rowCount == 0 {
            // Display a message when the table is empty
            // 没有数据的时候，UILabel的显示样式
            let messageLabel = UILabel()
            
            messageLabel.text = message
            messageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            messageLabel.textColor = UIColor.lightGray
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            
            self.backgroundView = messageLabel
        } else {
            self.backgroundView = nil
        }
    }
    
    /**
     滚动到底部
     
     - parameter animated:
     */
    func scrollToBottom(_ section: Int = 0, animated: Bool = false) {
        if self.numberOfRows(inSection: section) > 0 {
            let indexPath: IndexPath = IndexPath(
                row: self.numberOfRows(inSection: section) - 1,
                section: section)
            
            self.scrollToRow(
                at: indexPath,
                at: UITableViewScrollPosition.bottom,
                animated: animated)
        }
    }
    
    /**
     滚动到底部
     
     - parameter animated:
     */
    func scrollToTop(_ section: Int = 0, animated: Bool = false) {
        let indexPath: IndexPath = IndexPath(
            row: 0,
            section: section)
        
        self.scrollToRow(
            at: indexPath,
            at: UITableViewScrollPosition.bottom,
            animated: animated)
    }
}
