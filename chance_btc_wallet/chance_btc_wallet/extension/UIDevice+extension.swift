//
//  Device+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/2/15.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    //获得设备型号
    class func getDeviceVersion() -> String {
        let name = UnsafeMutablePointer<utsname>.allocate(capacity: 1)
        uname(name)
        let machine = withUnsafePointer(to: &name.pointee.machine, { (ptr) -> String? in
            
            let int8Ptr = unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)
            return String(cString: int8Ptr)
        })
        name.deallocate(capacity: 1)
        if let deviceString = machine {
            switch deviceString {
                //iPhone
            case "iPhone1,1":
                return "iPhone 1G"
            case "iPhone1,2":
                return "iPhone 3G"
            case "iPhone2,1":
                return "iPhone 3GS"
            case "iPhone3,1", "iPhone3,2":
                return "iPhone 4"
            case "iPhone4,1":
                return "iPhone 4S"
            case "iPhone5,1", "iPhone5,2":
                return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":
                return "iPhone 5C"
            case "iPhone6,1", "iPhone6,2":
                return "iPhone 5S"
            case "iPhone7,1":
                return "iPhone 6 Plus"
            case "iPhone7,2":
                return "iPhone 6"
            case "iPhone8,1":
                return "iPhone 6s"
            case "iPhone8,2":
                return "iPhone 6s Plus"
            default:
                return deviceString
            }
        } else {
            return ""
        }
    }
    
}
