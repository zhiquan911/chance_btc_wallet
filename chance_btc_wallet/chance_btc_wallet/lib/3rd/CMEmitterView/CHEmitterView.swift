//
//  CHEmitterView.swift
//  彩带动画
//
//  Created by CM on 2017/3/13.
//  Copyright © 2017年 CM. All rights reserved.
//

import UIKit

@IBDesignable
class CHEmitterView: UIView {
    
   
    let emitterLayer = CAEmitterLayer()
    let emitterCell = CAEmitterCell()
    var timer = Timer()
    

    // 平面的发射方向
    @IBInspectable public var emissionLongitude = CGFloat(M_PI) {
        didSet {
            self.emitterCell.emissionLatitude = emissionLongitude
        }
    }
    // 粒子速度
    @IBInspectable public var velocity:CGFloat = 100 {
        didSet {
            self.emitterCell.velocity = velocity
        }
    }
    // 粒子自旋转角度
    @IBInspectable public var spin = CGFloat(M_PI_2) {
        didSet {
            self.emitterCell.spin = spin
        }
    }
    // 粒子消失时间
    @IBInspectable public var lifetime = 4 {
        didSet {
            self.emitterCell.lifetime = Float(lifetime)
        }
    }
    // 粒子图片
    @IBInspectable public var backgroundImage = UIImage().cgImage {
        didSet {
            self.emitterCell.contents = backgroundImage
        }
    }
    
    // 粒子纵向加速度
    @IBInspectable public var yAcceleration = 50 {
        didSet {
            self.emitterCell.yAcceleration = CGFloat(yAcceleration)
        }
    }
    // 粒子横向加速度
    @IBInspectable public var xAcceleration = 0 {
        didSet {
            self.emitterCell.xAcceleration = CGFloat(xAcceleration)
        }
    }
    
    
    // 发射器中心位置
    @IBInspectable public var emitterPosition = CGPoint(x: UIScreen.main.bounds.width/2, y: 0) {
        didSet {
            self.emitterLayer.emitterPosition = emitterPosition
        }
    }
    // 发射器尺寸
    @IBInspectable public var emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 100) {
        didSet {
            self.emitterLayer.emitterSize = emitterSize
        }
    }
    
    // 发射器样式
    @IBInspectable public var emitterShape = kCAEmitterLayerLine {
        didSet {
            self.emitterLayer.emitterShape = emitterShape
        }
    }
    
   
    
    var birthRate: Float = 0 {
        didSet {
           self.emitterCell.birthRate = birthRate
        }
    }
    
    // 是否重复彩带
    var isRepeatEmitter: Bool = false {
        didSet {
            
        }
    }
    
    // 延迟时间
    var delayTime: TimeInterval = 0.3 {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        
    }
    
    
    func setup() {
        
        
        // 粒子
        emitterCell.name = "smoke"
        emitterCell.emissionLongitude  = emissionLongitude// emissionLongitude:x-y 平面的 发 射方向
        emitterCell.velocity = velocity// 粒子速度
        emitterCell.velocityRange = 50// 粒子速度范围
        emitterCell.emissionRange = CGFloat(M_PI_2)
        emitterCell.spin = spin
        emitterCell.spinRange = CGFloat(M_PI_2)
        
        //        emitterCell.scaleSpeed = -0.2// 缩放比例 超大火苗
        emitterCell.scale = 0.5
        emitterCell.color = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).cgColor
        emitterCell.alphaRange = 1
        emitterCell.redRange = 255
        emitterCell.blueRange = 22
        emitterCell.greenRange = 1.5
        //        emitterCell.greenSpeed = -0.1
        //        emitterCell.redSpeed = -0.2
        //        emitterCell.blueSpeed = 0.1
        //        emitterCell.alphaSpeed = -0.2
        //        emitterCell.birthRate = 100
        emitterCell.lifetime = Float(lifetime)
        //        emitterCell.color = UIColor.white.cgColor
        emitterCell.contents = backgroundImage
        
        // 粒子的初始加速度
        emitterCell.xAcceleration = CGFloat(xAcceleration)
        emitterCell.yAcceleration = CGFloat(yAcceleration)
        
        
        
        // 图层
        //        emitterLayer.position = self.view.center// 粒子发射位置
        emitterLayer.emitterPosition = emitterPosition
        emitterLayer.emitterSize = emitterSize
        //        emitterLayer.emitterSize = CGSize(width: 2, height: 2)// 控制粒子大小
        //        emitterLayer.renderMode = kCAEmitterLayerBackToFront
        //        emitterLayer.emitterMode = kCAEmitterLayerOutline// 控制发射源模式 即形状
        //        emitterLayer.emitterShape = kCAEmitterLayerCircle
        emitterLayer.preservesDepth = true
        emitterLayer.emitterDepth = 2.0
        
        /*
         public let kCAEmitterLayerPoint: String
         
         @available(iOS 5.0, *)
         public let kCAEmitterLayerLine: String
         
         @available(iOS 5.0, *)
         public let kCAEmitterLayerRectangle: String
         
         @available(iOS 5.0, *)
         public let kCAEmitterLayerCuboid: String
         
         @available(iOS 5.0, *)
         public let kCAEmitterLayerCircle: String
         
         @available(iOS 5.0, *)
         public let kCAEmitterLayerSphere: String
         */
        
        emitterLayer.emitterShape = emitterShape
        emitterLayer.spin = 100
        emitterLayer.emitterCells = [emitterCell]
        
        
        emitterCell.birthRate = birthRate

//        emitterCell.birthRate = birthRate
//        self.layer.addSublayer(emitterLayer)
        
        
    }
    
    // 停止彩带
    func stopEmitter() {
        self.emitterLayer.setValue(0, forKeyPath: "emitterCells.smoke.birthRate")
        _ = self.delay(TimeInterval(self.lifetime), task: {
            self.emitterLayer.removeFromSuperlayer()
        })
        
    }
    
    
    // 开始彩带
    func beginEmitter() {
        
        if self.isRepeatEmitter == false {
            self.addViewLayer()
            _ = self.delay(self.delayTime) {
                self.emitterLayer.setValue(0, forKeyPath: "emitterCells.smoke.birthRate")
                _ = self.delay(TimeInterval(self.lifetime), task: {
                    self.emitterLayer.removeFromSuperlayer()
                })
            }

        } else {
            self.addViewLayer()
        }
        
    }

}


extension CHEmitterView {
    
    // 添加动画
    func addViewLayer() {
        let viewLayer = UIApplication.shared.windows.first
        viewLayer?.layer.addSublayer(self.emitterLayer)
        self.emitterLayer.setValue(self.birthRate, forKeyPath: "emitterCells.smoke.birthRate")
    }

    
    typealias Task = (_ cancel : Bool) -> ()
    //延迟执行
    func delay(_ time:TimeInterval, task:@escaping ()->()) ->  Task? {
        
        func dispatch_later(_ block:@escaping ()->()) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                execute: block)
        }
        
        let closure = task
        var result: Task?
        
        let delayedClosure: Task = {
            cancel in
            if (cancel == false) {
                DispatchQueue.main.async(execute: closure);
            }
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result;
    }

}










