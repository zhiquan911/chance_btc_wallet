//
//  CHButton.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/29.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

@IBDesignable
class CHButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColorNormal: UIColor? {
        didSet {
            self.setBackgroundImage(self.imageWithColor(self.bgColorNormal!), for: .normal)
        }
    }
    
    @IBInspectable var bgColorHighlighted: UIColor? {
        didSet {
            self.setBackgroundImage(self.imageWithColor(self.bgColorHighlighted!), for: .highlighted)
        }
    }

    @IBInspectable var bgColorDisabled: UIColor? {
        didSet {
            self.setBackgroundImage(self.imageWithColor(self.bgColorDisabled!), for: .disabled)
        }
    }
    
    /**
     把颜色转为图片对象
     
     - parameter color:
     
     - returns:
     */
    func imageWithColor(_ color: UIColor) -> UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }

}

// MARK: - 为IB界面配置模拟数据
extension CHButton {
    
    
    /// 模拟数据调试
    public override func prepareForInterfaceBuilder() {

    }
}
