//
//  TabBarViewController.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/16.
//  Copyright © 2015年 Chance. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CHWalletWrapper.checkBTCWalletExist() {
            let vc = StoryBoard.welcome.initView(name: "WelcomeNavController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        } else {
            
            let index = CHBTCWallet.sharedInstance.selectedAccountIndex
            if index == -1 {
                let account = CHBTCWallet.sharedInstance.getAccount()
                CHBTCWallet.sharedInstance.selectedAccountIndex = account!.index
            }
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     配置UI
     */
    func setupUI() {
        
        //自定义tabbar的背景颜色和图标，只能是用代码设置才有效果
        self.tabBar.tintColor = UIColor.white
        
        //自定义tabbarItem的图标
        let tabBarItem1 = self.tabBar.items?[0]
        tabBarItem1?.image = UIImage(named: "menu_ico_asset")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem1?.selectedImage = UIImage(named: "menu_ico_asset_active")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.viewControllers![0].tabBarItem = tabBarItem1
        
        let tabBarItem2 = self.tabBar.items?[1]
        tabBarItem2?.image = UIImage(named: "menu_ico_user")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem2?.selectedImage = UIImage(named: "menu_ico_user_active")?
            .withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.viewControllers![1].tabBarItem = tabBarItem2
        
        //改变UITabBarItem 字体颜色
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor(hex: 0x505050)],
            for: UIControlState())
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor(hex: 0xE30B17)],
            for: UIControlState.selected)
        
        
    }
    
}
