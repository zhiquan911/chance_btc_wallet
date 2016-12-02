//
//  UIView+MotionEffect.swift
//  Chance_wallet
//
//  Created by Chance on 16/8/6.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

// MARK: - MotionEffect 根据设备重力感应实现UIView视差效果

extension UIView {
    
    //在扩展中通过key来定义成员变量
    fileprivate struct AssociatedKeys {
        static var motionEffectFlag = "motionEffectFlag"
    }
    
    //通过AssociatedKeys的值定义成员变量
    var effectGroup: UIMotionEffectGroup? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.motionEffectFlag) as? UIMotionEffectGroup
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.motionEffectFlag,
                newValue as UIMotionEffectGroup?,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    
    func addXAxisWithValue(_ xValue: CGFloat, yValue: CGFloat) {
        if (xValue >= 0) && (yValue >= 0) {
            let xAxis = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
            
            xAxis.minimumRelativeValue = -xValue
            xAxis.maximumRelativeValue = xValue
            
            let yAxis = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)

            yAxis.minimumRelativeValue = -yValue
            yAxis.maximumRelativeValue = yValue
            
            // 先移除效果再添加效果
            self.effectGroup?.motionEffects = nil
            self.removeMotionEffect(self.effectGroup!)
            self.effectGroup?.motionEffects = [xAxis, yAxis]
            
            // 给view添加效果
            self.addMotionEffect(self.effectGroup!)
        }
    }
    
    func removeSelfMotionEffect() {
        self.removeMotionEffect(self.effectGroup!)
    }
}
