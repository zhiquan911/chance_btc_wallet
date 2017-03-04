//
//  BaseViewController.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/21.
//  Copyright © 2015年 Chance. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     配置导航栏
     */
    func ch_setupNavigationBar() {
        //配置返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
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
