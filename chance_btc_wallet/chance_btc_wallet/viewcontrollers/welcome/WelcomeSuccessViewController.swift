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

    //彩带飘落效果
    var emitterView = CHEmitterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.showCongratulations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emitterView.beginEmitter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// 发礼炮
    func showCongratulations() {
        self.emitterView.backgroundImage = UIImage(named: "congalts")?.cgImage
        self.emitterView.birthRate = 300
        self.emitterView.delayTime = 2
    }

}


// MARK: - 控制器方法
extension WelcomeSuccessViewController {
    
    
    /// 配置UI
    func setupUI() {
        self.navigationItem.title = "Congratulations".localized()
        self.navigationItem.hidesBackButton = true
        self.labelSuccess.text = "Congratulations"
        self.labelTips.text = "Use Bitcoin To Change Your Life".localized()
        self.buttonGo.setTitle("Let's Go".localized(), for: .normal)
    }
    
    @IBAction func handleGoHomePress() {
        AppDelegate.sharedInstance().restoreRootTabController()
    }
}
