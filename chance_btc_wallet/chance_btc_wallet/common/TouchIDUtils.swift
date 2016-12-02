//
//  TouchIDUtils.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/7.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import LocalAuthentication

class TouchIDUtils: NSObject {
    
    /// MARK: - 回调
    typealias Complete = (_ flag: Bool, _ error: String?) -> Void              //成功的回调
    typealias UserFallback = () -> Void         //用户输入密码
    
    /**
     是否支持指纹识别或开启了指纹识别
     
     - returns:
     */
    class func isTouchIDEnable() -> (Bool, String) {
        
        //初始化上下文对象
        let context = LAContext()
        
        //错误对象
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            return (true, "")
        } else {
            //不支持指纹识别，LOG出错误详情
            var msg = ""
            switch error!.code {
            case LAError.Code.touchIDNotEnrolled.rawValue:
                Log.debug("TouchID is not enrolled".localized());
                msg = "TouchID is not enrolled".localized()
                break;
            case LAError.Code.passcodeNotSet.rawValue:
                Log.debug("A passcode has not been set".localized());
                msg = "A passcode has not been set".localized()
                break;
            default:
                Log.debug("TouchID not available".localized());
                msg = "TouchID not available".localized()
                break;
            }
            return (false, msg)
        }
    }
    
    
    class func authenticateUser(
        _ reason: String,
        fallbackTitle: String = "",
        userFallback: UserFallback? = nil,
        complete: Complete?) {
        //初始化上下文对象
        let context = LAContext()
        context.localizedFallbackTitle = fallbackTitle
            
        //错误对象
        var error: NSError?
        
        //首先使用canEvaluatePolicy 判断设备支持状态
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: {
                (success, error) -> Void in
                if (success) {
                    //验证成功，主线程处理UI
                    DispatchQueue.main.async(execute: {
                        complete?(success, nil)
                    })
                    
                } else {
                    Log.debug("%@",error!.localizedDescription);
                    let error = error as! LAError
                    switch error.code {
                    case LAError.Code.systemCancel:
                        
                        Log.debug("Authentication was cancelled by the system".localized());
                        //切换到其他APP，系统取消验证Touch ID
                        
                        DispatchQueue.main.async(execute: {
                            complete?(success, "Authentication was cancelled by the system".localized())
                        })
                        break
                        
                    case LAError.Code.userCancel:
                        
                        Log.debug("Authentication was cancelled by the user".localized());
                        //用户取消验证Touch ID
                        DispatchQueue.main.async(execute: {
                            complete?(success, "Authentication was cancelled by the user".localized())
                        })
                        break;
                        
                    case LAError.Code.userFallback:
                        //用户选择输入密码
                        Log.debug("User selected to enter custom password".localized());
                        DispatchQueue.main.async(execute: {
                            userFallback?()
                        })
                        break;
                        
                    default:
                        DispatchQueue.main.async(execute: {
                            complete?(success, "")
                        })
                        break;
                        
                    }
                }
            })
        } else {
            //不支持指纹识别
            DispatchQueue.main.async(execute: {
                userFallback?()
            })
        }
    }
    
}
