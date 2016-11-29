//
//  BaseViewController.swift
//  chbtc
//
//  Created by 麦志泉 on 15/11/21.
//  Copyright © 2015年 bitbank. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     配置导航栏
     */
    func ch_setupNavigationBar() {
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
    }
}

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ch_setupNavigationBar()
    }
    
}

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ch_setupNavigationBar()
    }
}
