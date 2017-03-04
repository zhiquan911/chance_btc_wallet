//
//  AccountCreateCell.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/2.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class AccountCreateCell: UICollectionViewCell {

    //MARK: - 成员变量
    
    @IBOutlet var bgView: UIView!
    @IBOutlet var viewCenterLine: UIView!
    
    class var cellIdentifier: String{
        
        return "AccountCreateCell"
    }
    
    //MARK: - 重载方法
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //UICollectionViewCell配置圆角阴影方法
        //http://qingqinghebiancao.github.io/2016/01/12/iOS开发小技巧/
        
        // 将阴影加在cell上
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        //将圆角加在cell的ContentView上
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        
        //中间分割线
        self.viewCenterLine.backgroundColor = UIColor(patternImage: UIImage(named: "linedash")!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //在执行layoutSubviews才渲染阴影路径，因为layoutSubviews里才能获取self.bounds的正确值
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        
    }

}
