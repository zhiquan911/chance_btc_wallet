//
//  AppDelegate.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/22.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var rootTabController: TabBarViewController?

    class func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //隐藏键盘
    func closeKeyBoard() {
        self.window?.endEditing(false)
    }
    
    
    /// 把主控制器切换为TabController
    func restoreRootTabController(animated: Bool = true) {
        //动画过渡
        if animated {
            
            self.rootTabController?.modalTransitionStyle = .flipHorizontal
            
            let animation: () -> Void = {
                () -> Void in
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.window?.rootViewController = self.rootTabController
                UIView.setAnimationsEnabled(oldState)
            }
            
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: animation, completion: nil)
            
        } else {
            self.window?.rootViewController = self.rootTabController
        }
        
        
    }
    
    /// 把主控制器切换为初始创建钱包，重置钱包流程
    func restoreWelcomeController(animated: Bool = true) {
        
        let welcome = StoryBoard.welcome.initView(name: "WelcomeNavController") as! UINavigationController
        
        //动画过渡
        if animated {
            
            self.rootTabController?.modalTransitionStyle = .flipHorizontal
            
            let animation: () -> Void = {
                () -> Void in
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.window?.rootViewController = welcome
                UIView.setAnimationsEnabled(oldState)
            }
            
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromRight, animations: animation, completion: nil)
            
        } else {
            self.window?.rootViewController = welcome
        }
        
        
    }
    
    /**
     设置SVProgressHUD的样式
     */
    func setupSVProgressHUDStyle() {
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setAnimatedViewColor(UIColor.white)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }

    /**
     设置键盘控制
     */
    fileprivate func setupKeyboardManager() {
        //开启键盘自动适应高度
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(RestoreWalletViewController.self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.setupSVProgressHUDStyle()
        
        self.setupKeyboardManager()
        
        //默认的最底层控制器
        self.rootTabController = TabBarViewController.walletTab
        
        //如果没有钱包数据，先到欢迎界面引导创建钱包
        if !CHWalletWrapper.checkWalletRoot() {
            
            let welcome = StoryBoard.welcome.initView(name: "WelcomeNavController") as! UINavigationController
            self.window!.rootViewController = welcome
            
        } else {
            //有钱包数据就直接进入首页tabbar
            self.window!.rootViewController = self.rootTabController
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

