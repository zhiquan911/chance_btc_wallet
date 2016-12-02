//
//  UIViewController+extension.swift
//  Chance_wallet
//
//  Created by Chance on 15/11/21.
//  Copyright © 2015年 Chance. All rights reserved.
//

import Foundation

extension UIViewController {
    
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
    
    func cancel(_ task:Task?) {
        task?(true)
    }

    /**
     viewcontroller是否显示在当前window
     
     - returns:
     */
    var isVisible: Bool {
        if self.isViewLoaded && self.view.window != nil {
            return true
        } else {
            return false
        }
    }
}
