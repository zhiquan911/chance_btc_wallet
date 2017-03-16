//
//  UIView+extension.swift
//  light_guide
//
//  Created by Chance on 15/10/16.
//  Copyright © 2015年 wetasty. All rights reserved.
//

import Foundation
import UIKit

//MARK：全局方法
extension UIView {
    
    //读取nib文件
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

// MARK: - 动画
extension UIView {
    
    //不停360旋转
    func rotate360Degrees(_ duration: CFTimeInterval = 5, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        
        self.layer.add(rotateAnimation, forKey: "rotationAnimation")
    }
    
    //停止360旋转
    func stopRotate360Degrees() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    //左右振动
    func shakeLeftRightAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [0, NSNumber(value: 1 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 5 / 6.0), 1]
        animation.duration = 0.4;
        
        animation.isAdditive = true;
        self.layer.add(animation, forKey: "shake")
    }
    
    //上下振动
    func shakeUpDownAnimation(_ range: Float = 10) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.y"
        animation.values = [0, range, -range, range, 0]
        animation.keyTimes = [0, NSNumber(value: 1 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 5 / 6.0), 1]
        animation.duration = 0.8;
        
        animation.isAdditive = true;
        self.layer.add(animation, forKey: "shake")
    }
    
    
}

// MARK: - 形状坐标相关
extension UIView {
    
    var x: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.x = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var y: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.y = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var centerX: CGFloat {
        set {
            var center = self.center;
            center.x = newValue;
            self.center = center;
        }
        get {
            return self.center.x
        }
    }
    
    var centerY: CGFloat {
        set {
            var center = self.center;
            center.y = newValue;
            self.center = center;
        }
        get {
            return self.center.y
        }
    }
    
    var width: CGFloat {
        set {
            var frame = self.frame;
            frame.size.width = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.size.width
        }
    }
    
    var height: CGFloat {
        set {
            var frame = self.frame;
            frame.size.height = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.size.height
        }
    }
    
    var size: CGSize {
        set {
            var frame = self.frame;
            frame.size = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.size
        }
    }
}

// MARK: - 角标红点定制
extension UIView {
    
    var badgeViewTag: Int {
        return 777
    }
    
    /**
     显示小红点
     
     - parameter index: 位置
     */
    func showBadge(_ x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat = 10, height: CGFloat = 10) {
        //移除之前的小红点
        self.removeBadge()
        
        //新建小红点
        let badgeView = UIView()
        badgeView.tag = self.badgeViewTag;
        badgeView.layer.cornerRadius = 5;//圆形
        badgeView.layer.masksToBounds = true
        badgeView.backgroundColor = UIColor.red //颜色：红色
        let frame = self.frame;
        
        //确定小红点的位置
        var x = x
        if x == nil {
            x = 0
            x = frame.size.width + width
        }
        var y = y
        if y == nil {
            y = 0
            y = (frame.size.height - height) / 2
        }
        badgeView.frame = CGRect(x: CGFloat(x!), y: CGFloat(y!), width: width, height: height);//圆形大小为10
        self.addSubview(badgeView)
    }
    
    /**
     隐藏小红点
     
     - parameter index: 位置
     */
    func hideBadge() {
        //移除小红点
        self.removeBadge()
    }
    
    /**
     移除小红点
     
     - parameter index:
     */
    func removeBadge() {
        //按照tag值进行移除
        for subView in self.subviews {
            if (subView.tag == self.badgeViewTag) {
                subView.removeFromSuperview()
            }
        }
    }
}


// MARK: - 使用原生的UIMenu式弹出自定义菜单栏
extension UIView {
    
    
    /// 弹出UIMenu式菜单
    ///
    /// - Parameters:
    ///   - items: 菜单项
    ///   - containerView: 弹出显示菜单时所在范围的容器（View）
    func showUIMenu(items: [UIMenuItem], containerView: UIView) {
        
        //已经是第一响应就消除
        if containerView.isFirstResponder {
            containerView.resignFirstResponder()
        }
        
        //把自己设置为第一响应才能弹出菜单
        containerView.becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        menuController.menuItems = items
        //设置 menu 的 frame和父 view
        guard let newFrame = self.superview?.convert(self.frame, to: containerView) else {
            return
        }
        menuController.setTargetRect(newFrame, in: containerView)
        menuController.setMenuVisible(true, animated: true)
    }
}


