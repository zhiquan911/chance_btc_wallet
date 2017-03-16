//
//  WelcomeSuccessViewController.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/8.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class WelcomeSuccessViewController: UIViewController {
    
    @IBOutlet var labelSuccess: UILabel!
    @IBOutlet var buttonGo: UIButton!
    @IBOutlet var labelTips: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - 控制器方法
extension WelcomeSuccessViewController {
    
    
    /// 配置UI
    func setupUI() {
        
        self.navigationItem.title = "Congratulations".localized()
        self.labelTips.text = "Use Bitcoin To Change Your Life".localized()
        self.buttonGo.setTitle("Let's Go".localized(), for: .normal)
    }
    
    @IBAction func handleGoHomePress() {
        AppDelegate.sharedInstance().restoreRootTabController()
    }
}
