//
//  CHView.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/7.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

@IBDesignable
class CHView: UIView {

    /// 设置一个可拉伸的背景图
    @IBInspectable var backgroudImage: UIImage? {
        didSet {
            self.layer.contents = self.backgroudImage?.cgImage
            self.layer.backgroundColor = UIColor.clear.cgColor
            //contentsCenter为拉伸部分，以比例设置，x: 0.5, y: 0.5代表中间位置
            //width: 0, height: 0,代表从中间开始向左右上下拉伸
            self.layer.contentsCenter = CGRect(x: 0.5, y: 0.5, width: 0, height: 0)
            self.layer.contentsScale = UIScreen.main.scale
        }
    }

}
