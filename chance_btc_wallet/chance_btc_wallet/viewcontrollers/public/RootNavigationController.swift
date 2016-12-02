//
//  RootNavigationController.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/16.
//  Copyright © 2015年 Chance. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationBar.setBackgroundImage(UIColor.imageWithColor(UIColor(hex: 0x2E3F53)), for: UIBarMetrics.default)
        self.navigationBar.isTranslucent = false
        
        //文字颜色
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ]
        UINavigationBar.appearance().tintColor = UIColor.white
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = UIColor.clear
    }

    //MARK: ios7状态栏修改
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
