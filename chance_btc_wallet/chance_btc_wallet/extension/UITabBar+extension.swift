//
//  UITabBar+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/4/9.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension UITabBar {
    
    /**
     显示小红点
     
     - parameter index: 位置
     */
    func showBadgeOnItemIndex(_ index: Int) {
        //移除之前的小红点
        self.removeBadgeOnItemIndex(index)
        
        //新建小红点
        let badgeView = UIView()
        badgeView.tag = 888 + index;
        badgeView.layer.cornerRadius = 5;//圆形
        badgeView.backgroundColor = UIColor.red //颜色：红色
        let tabFrame = self.frame;
        
        let tabbarItemNums = self.items!.count
        //确定小红点的位置
        let percentX: Float = (Float(index) + 0.6) / Float(tabbarItemNums)
        let x = ceilf(percentX * Float(tabFrame.size.width));
        let y = ceilf(0.1 * Float(tabFrame.size.height));
        badgeView.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: 10, height: 10);//圆形大小为10
        self.addSubview(badgeView)
    }
    
    /**
     隐藏小红点
     
     - parameter index: 位置
     */
    func hideBadgeOnItemIndex(_ index: Int) {
        //移除小红点
        self.removeBadgeOnItemIndex(index)
    }
    
    /**
     移除小红点
     
     - parameter index:
     */
    func removeBadgeOnItemIndex(_ index: Int){
        //按照tag值进行移除
        for subView in self.subviews {
            if (subView.tag == 888+index) {
                subView.removeFromSuperview()
            }
        }
    }
}
