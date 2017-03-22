//
//  CHNavigationButton.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/22.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

public class CHNavigationButton: UIButton {
    
    typealias DoWhat = () -> Void
    var doWhat: DoWhat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String, block: @escaping DoWhat) {
        let size = title.textSizeWithFont(UIFont.boldSystemFont(ofSize: 17), constrainedToSize: CGSize(width: 2000,height: 2000))
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.setTitle(title, for: UIControlState())
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel!.minimumScaleFactor = 0.5
        self.titleLabel!.adjustsFontSizeToFitWidth = true
        self.titleLabel!.textColor = UIColor.white
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.setTitleColor(UIColor.darkText, for: UIControlState.highlighted)
        self.setTitleColor(UIColor.darkText, for: UIControlState.selected)
        self.addTarget(self, action: #selector(self.buttonPress), for: UIControlEvents.touchUpInside)
        
        doWhat = block
        
    }
    
    convenience init(image: UIImage, size: CGSize? = nil, block: @escaping DoWhat) {
        var mSize = size
        if mSize == nil {
            mSize = CGSize(width: image.size.width, height: image.size.height)
        }
        self.init(frame: CGRect(x: 0, y: 0, width: mSize!.width, height: mSize!.height))
        self.setImage(image, for: UIControlState())
        self.setImage(image, for: UIControlState.highlighted)
        self.addTarget(self, action: #selector(self.buttonPress), for: UIControlEvents.touchUpInside)
        
        doWhat = block
    }
    
    convenience init(title: String, image: UIImage, block: @escaping DoWhat) {
        
        let size = title.textSizeWithFont(UIFont.systemFont(ofSize: 17), constrainedToSize: CGSize(width: 2000,height: 2000))
        let height: CGFloat = image.size.height > size.height ? image.size.height:size.height;
        
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: size.width + image.size.width + 10, height: height))
        self.setTitle(title, for: UIControlState())
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel!.minimumScaleFactor = 0.5
        self.titleLabel!.adjustsFontSizeToFitWidth = true
        self.titleLabel!.textColor = UIColor.white
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        self.setTitleColor(UIColor.white, for: UIControlState.selected)
        self.setImage(image, for: UIControlState())
        self.setImage(image, for: UIControlState.highlighted)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        self.addTarget(self, action: #selector(self.buttonPress), for: UIControlEvents.touchUpInside)
        
        doWhat = block
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //点击按钮事件
    func buttonPress() {
        self.doWhat?()
    }
    
}

extension UINavigationBar {
    
    /*!
     * @method 获取按钮
     * @abstract
     * @discussion
     * @param   title：标题
     * @param   block：点击时间
     * @result
     */
    func getButtonWithTitle(_ title: String, andActionBlock:@escaping () -> Void) -> UIBarButtonItem {
        
        let barbutton: UIBarButtonItem
        let button = CHNavigationButton(title: title, block: andActionBlock)
        barbutton = UIBarButtonItem(customView: button);
        return barbutton;
    }
    
    /*!
     * @method 获取按钮
     * @abstract
     * @discussion
     * @param   title：图片
     * @param   block：点击时间
     * @result
     */
    func getButtonWithImage(_ image: UIImage, andActionBlock:@escaping () -> Void) -> UIBarButtonItem {
        
        let barbutton: UIBarButtonItem
        let button = CHNavigationButton(image: image, block: andActionBlock)
        barbutton = UIBarButtonItem(customView: button);
        return barbutton;
    }
    
    
    func getButtonWithImage(_ image: UIImage, size: CGSize, andActionBlock:@escaping () -> Void) -> UIBarButtonItem {
        
        let barbutton: UIBarButtonItem
        let button = CHNavigationButton(image: image, size: size, block: andActionBlock)
        barbutton = UIBarButtonItem(customView: button);
        return barbutton;
    }
    
    
    
    
    /**
     *  获取按钮
     *
     *  @param title 文字
     *  @param image 图标
     *  @param block 点击事件
     *
     *  @return
     */
    func getButtonWithTitle(_ title: String, andImage: UIImage, andActionBlock:@escaping () -> Void) -> UIBarButtonItem {
        let barbutton: UIBarButtonItem
        let button = CHNavigationButton(title: title, image: andImage, block: andActionBlock)
        barbutton = UIBarButtonItem(customView: button);
        return barbutton;
    }
    
}
