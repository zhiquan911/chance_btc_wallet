//
//  BaseViewController.swift
//  chbtc
//
//  Created by 麦志泉 on 15/11/21.
//  Copyright © 2015年 bitbank. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    /**
     配置导航栏
     */
    func setupNavigationBar() {
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
