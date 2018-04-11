//
//  NSTimer+extension.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/21.
//  Copyright © 2015年 Chance. All rights reserved.
//

import Foundation

/// Empty arguments and non-return value closure
public typealias VoidClosure = () ->Void

/// Private void closure key
let private_voidClosureKey = "private_voidClosureKey"
let private_countKey = "private_countKey"

/// Array's useful extensions.
///
/// Author: huangyibiao
/// Github: http://github.com/CoderJackyHuang/
/// Blog:   http://www.hybblog.com/
public extension Timer {
    // MARK: Public
    
    ///  This is a very convenience Api for us to create a timer and just call back with a closure.
    ///
    ///  - parameter timeInterval: The interval time for a tick, default is one second.
    ///  - parameter repeats:      Whether to repeat callback when interval time comes
    ///  - parameter callback:     The selector for calling back.
    ///
    ///  - returns: The created timer object.
    public class func schedule(_ timeInterval: TimeInterval = 1, repeats: Bool, callback: VoidClosure?) ->Timer {
        return Timer.schedule(timeInterval, userInfos: nil, repeats: repeats, callback: callback, count: nil)
    }
    
    ///  This is a very convenience Api for us to create a timer and just call back with a closure.
    ///  We can use count argument to specify how many times to tick. If count is zero, it means repeats.
    ///
    ///  - parameter timeInterval: The interval time for a tick, default is one second.
    ///  - parameter count:        How many counts to call back. Zero means repeats.
    ///  - parameter callback:     The selector for calling back.
    ///
    ///  - returns: The created timer object.
    public class func schdule(_ timeInterval: TimeInterval = 1, count: Int?, callback: VoidClosure?) ->Timer {
        return Timer.schedule(timeInterval, userInfos: nil, repeats: true, callback: callback, count: count)
    }
    
    // MARK: Private
    @objc internal class func  private_onTimerCallback(_ timer: Timer) {
        struct private_count {
            static var s_timerCallbackCount: Int = NSNotFound
        }
        
        if private_count.s_timerCallbackCount == NSNotFound {
            if let wrapper = timer.userInfo as? HYBObjectWrapper {
                if let count = wrapper.count {
                    private_count.s_timerCallbackCount = count
                }
            }
        }
        
        if private_count.s_timerCallbackCount != NSNotFound {
            private_count.s_timerCallbackCount -= 1
            if private_count.s_timerCallbackCount < 0 {
                timer.invalidate()
                return
            }
        }
        
        var hasCalled = false
        if let wrapper = timer.userInfo as? HYBObjectWrapper {
            if let callback = wrapper.voidClosure {
                callback()
                hasCalled = true
            }
        }
        
        if !hasCalled {
            timer.invalidate()
        }
    }
    
    fileprivate class func schedule(_ timeInterval: TimeInterval, userInfos: AnyObject?, repeats: Bool, callback: VoidClosure?, count: Int?) ->Timer {
        var count = count
        var repeats = repeats
        if count == 0 {
            repeats = true
            count = nil
        }
        
        let wrapper = HYBObjectWrapper(closure: callback, userInfos: userInfos, count: count)
        
        
        let timer = Timer.scheduledTimer(timeInterval: timeInterval,
            target: self,
            selector: #selector(Timer.private_onTimerCallback(_:)),
            userInfo: wrapper,
            repeats: repeats)
        
        return timer
    }
}

/// 私有类
private class HYBObjectWrapper: NSObject {
    var voidClosure: VoidClosure?
    var userInfos: AnyObject?
    var count: Int?
    
    init(closure: VoidClosure?, userInfos: AnyObject?, count: Int?) {
        self.voidClosure = closure
        self.userInfos = userInfos
        self.count = count
    }
}
