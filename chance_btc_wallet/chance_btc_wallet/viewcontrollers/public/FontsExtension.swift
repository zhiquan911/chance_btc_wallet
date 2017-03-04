//
//  FontsExtension.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/2/25.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

/*
extension UIFont {
    
    @objc class func myPreferredFont(forTextStyle style: String) -> UIFont {
        let defaultFont = myPreferredFont(forTextStyle: style)  // don´t know but it works...
        let newDescriptor = defaultFont.fontDescriptor.withFamily(defaultFontFamily)
        return UIFont(descriptor: newDescriptor, size: defaultFont.pointSize)
    }
    
    @objc fileprivate class func mySystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize)
    }
    
    @objc fileprivate class func myBoldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize, withTraits: .traitBold)
    }
    
    @objc fileprivate class func myItalicSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize, withTraits: .traitItalic)
    }
    
    fileprivate class func myDefaultFont(ofSize fontSize: CGFloat, withTraits traits: UIFontDescriptorSymbolicTraits = []) -> UIFont {
        let descriptor = UIFontDescriptor(name: defaultFontFamily, size: fontSize).withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: fontSize)
    }
}

extension UIFont {
    
    class var defaultFontFamily: String { return "Menlo" }
    
    override open class func initialize() {
        
        if self == UIFont.self {
            _ = {
                swizzleSystemFont()
                
            }()
        }
    }
    
    private class func swizzleSystemFont() {
        
        let systemPreferredFontMethod = class_getClassMethod(self, #selector(UIFont.preferredFont(forTextStyle:)))
        let mySystemPreferredFontMethod = class_getClassMethod(self, #selector(UIFont.myPreferredFont(forTextStyle:)))
        method_exchangeImplementations(systemPreferredFontMethod, mySystemPreferredFontMethod)
        
        let systemFontMethod = class_getClassMethod(self, #selector(UIFont.systemFont(ofSize:)))
        let mySystemFontMethod = class_getClassMethod(self, #selector(UIFont.mySystemFont(ofSize:)))
        method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        
        let boldSystemFontMethod = class_getClassMethod(self, #selector(UIFont.boldSystemFont(ofSize:)))
        let myBoldSystemFontMethod = class_getClassMethod(self, #selector(UIFont.myBoldSystemFont(ofSize:)))
        method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        
        let italicSystemFontMethod = class_getClassMethod(self, #selector(UIFont.italicSystemFont(ofSize:)))
        let myItalicSystemFontMethod = class_getClassMethod(self, #selector(UIFont.myItalicSystemFont(ofSize:)))
        method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
    }
}

*/

