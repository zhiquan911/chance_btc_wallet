//
//  UIColor+extension.swift
//  light_guide
//
//  Created by Chance on 15/10/19.
//  Copyright © 2015年 wetasty. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     16进制表示颜色
     
     - parameter hex:
     
     - returns:
     */
    convenience init(hex: UInt, alpha: Float = 1.0) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha))
    }

    
    
}

// MARK: - 全局方法
extension UIColor {
    
    /**
     把颜色转为图片对象
     
     - parameter color:
     
     - returns:
     */
    class func imageWithColor(_ color: UIColor) -> UIImage{
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
