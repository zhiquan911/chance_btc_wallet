//
//  AppDelegate.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/22.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    class func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //隐藏键盘
    func closeKeyBoard() {
        self.window?.endEditing(false)
    }
    
    /**
     设置SVProgressHUD的样式
     */
    func setupSVProgressHUDStyle() {
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setAnimatedViewColor(UIColor.white)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setMinimumDismissTimeInterval(5)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //清空钱包所有数据，用于调试
        //CHWalletWrapper.deleteAllWallets()
        
        self.setupSVProgressHUDStyle()
        
        //开启icloud同步
        //RealmDBHelper.shared.iCloudEnable = true
        
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

