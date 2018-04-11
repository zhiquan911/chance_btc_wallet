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
    
    /// 配置导航栏背景
    func setupNavigationBar() {
        
        let bgImg = UIImage(named: "navbar_bg")?.resizableImage(
            withCapInsets: UIEdgeInsets.zero,
            resizingMode: UIImageResizingMode.stretch)
        
        self.navigationBar.setBackgroundImage(bgImg,
                                              for: UIBarMetrics.default)
        self.navigationBar.isTranslucent = false
        
        
        //文字颜色
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "Menlo-Bold", size: 17)!
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
