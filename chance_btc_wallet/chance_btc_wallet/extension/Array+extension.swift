//
//  Array+extension.swift
//  light_guide
//
//  Created by Chance on 15/10/8.
//  Copyright © 2015年 wetasty. All rights reserved.
//

import Foundation
extension Array where Element: Equatable {
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}
