//
//  File.swift
//  Chance_wallet
//
//  Created by Chance on 16/3/14.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension ZYQAssetPickerController {
    
    class func getInstanceWithCustomNav() -> ZYQAssetPickerController {
        let picker = ZYQAssetPickerController()
        
        //修改导航栏颜色
        picker.setNavigationBar(UIColor(hex: 0x2E3F53),textColor: UIColor.white, isShadow: false)
        return picker
    }
    
    //修改导航栏颜色
    func setNavigationBar(_ bgColor: UIColor = UIColor.clear, textColor: UIColor = UIColor.black, isShadow: Bool = true) {
        
        //修改导航栏颜色
        let navBar = self.navigationBar
        
        navBar.setBackgroundImage(UIColor.imageWithColor(bgColor), for: UIBarMetrics.default)
        navBar.isTranslucent = false
        
        //文字颜色
        navBar.tintColor = textColor
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17),
            
        ]
        UINavigationBar.appearance().tintColor = textColor
        //    为什么要加这个呢，shadowImage 是在ios6.0以后才可用的。但是发现5.0也可以用。不过如果你不判断有没有这个方法，
        //    而直接去调用可能会crash，所以判断下。作用：如果你设置了上面那句话，你会发现是透明了。但是会有一个阴影在，下面的方法就是去阴影
        if !isShadow {
            navBar.shadowImage = UIImage()
        }
        //    以上面4句是必须的,但是习惯还是加了下面这句话
        navBar.backgroundColor = UIColor.clear
    }
    
    
    //MARK: ios7状态栏修改
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override open var prefersStatusBarHidden : Bool {
        return false
    }
}
