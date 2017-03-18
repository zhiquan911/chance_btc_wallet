//
//  PeddingSignatureView.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/15.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class PeddingSignatureView: UIView {

    var labelAddres: UILabel?
    var imageViewAvatar: UIImageView?
    
    var address: String = "" {
        didSet {
            self.labelAddres?.text = self.address
        }
    }

    
    func initUI() {
        
        /********* 初始化 *********/
        self.labelAddres = UILabel()
        self.labelAddres?.translatesAutoresizingMaskIntoConstraints = false
        self.labelAddres?.textColor = UIColor.lightGray
        self.labelAddres?.font = UIFont.systemFont(ofSize: 14)
        self.labelAddres?.textColor = UIColor(hex: 0x999999)
        self.labelAddres?.minimumScaleFactor = 0.5
        self.labelAddres?.adjustsFontSizeToFitWidth = true
        self.labelAddres?.numberOfLines = 1
        self.labelAddres?.text = ""
        self.addSubview(self.labelAddres!)
        
        self.imageViewAvatar = UIImageView(image: UIImage(named: "icon_signature_avatar"))
        self.imageViewAvatar?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageViewAvatar!)
        
        self.backgroundColor = UIColor(hex: 0xFBFBFB)
        self.layer.borderColor = UIColor(hex: 0xF3F3F3).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 3
        self.layer.masksToBounds  = true
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
        self.layoutUI()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //为何要在awakeFromNib再执行布局，因为awakeFromNib之后就可以得到真正的设备尺寸。
        //init?(coder aDecoder: NSCoder)时，还未得到真正的设备尺寸。
        self.layoutUI()
    }
    
}


// MARK: - 内部方法
extension PeddingSignatureView {
    
    
    /// 布局设置
    func layoutUI() {
        
        
        
        /********* 约束布局 *********/
        
        let views: [String : Any] = [
            "labelAddres": self.labelAddres!,
            "imageViewAvatar": self.imageViewAvatar!
        ]
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-8-[imageViewAvatar(==10)]-4-[labelAddres]-8-|",
            options: .alignAllCenterY,
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[imageViewAvatar(==11)]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        //垂直居中
        
        self.addConstraint(NSLayoutConstraint(
            item: self.imageViewAvatar!,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0))
        
   
    }
    
}

