//
//  String+extension.swift
//  light_guide
//
//  Created by 麦志泉 on 15/8/29.
//  Copyright (c) 2015年 wetasty. All rights reserved.
//

import Foundation

extension String {
    
/*
    - (NSString *)substringToDecimalNum:(NSInteger)num
    {
    NSString *tmpString = [self copy];
    if ([tmpString rangeOfString:@"."].location != NSNotFound) {
    if (num == 0) {
    return [tmpString substringToIndex:[tmpString rangeOfString:@"."].length];
    }
    
    
    if ([tmpString rangeOfString:@"."].location + num + 1 > tmpString.length) {
    while ([tmpString rangeOfString:@"."].location + num + 1 - tmpString.length > 0)
    {
    tmpString = [tmpString stringByAppendingString:@"0"];
    }
    return tmpString;
    }
    NSString *prefixString = [tmpString substringToIndex:[tmpString rangeOfString:@"."].location + num ];
    //        NSString *suffixString
    return [tmpString substringToIndex: [tmpString rangeOfString:@"."].location + num + 1];
    }else
    {
    tmpString = [tmpString stringByAppendingString:@"."];
    while (num > 0) {
    tmpString = [tmpString stringByAppendingString:@"0"];
    num--;
    }
    return tmpString;
    }
    }
*/
    
    
    /**
     *  正则表达式处理
 
    struct CHRegex {
        let regex: NSRegularExpression?
        
        init(_ pattern: String) {
            regex = try? NSRegularExpression(pattern: pattern,
                                             options: .CaseInsensitive)
        }
        
        func match(input: String) -> Bool {
            if let matches = regex?.matchesInString(input,
                                                    options: [],
                                                    range: NSMakeRange(0, (input as NSString).length)) {
                return matches.count > 0
            } else {
                return false
            }
        }
    }
     */
    
    /// 字符串长度
    var length: Int {
        return self.characters.count;
    }  // Swift 1.2
    
    
    /**
    计算文字的高度
    
    - parameter font:
    - parameter size:
    
    - returns: 
    */
    func textSizeWithFont(_ font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        let newStr = NSString(string: self)
        if size.equalTo(CGSize.zero) {
            let attributes = [NSFontAttributeName: font]
            textSize = newStr.size(attributes: attributes)
        } else {
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let attributes = [NSFontAttributeName: font]
            let stringRect = newStr.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
    
    // MARK: Trim API
    
    /// 去掉字符串前后的空格，根据参数确定是否过滤换行符
    ///
    /// - parameter trimNewline 是否过滤换行符，默认为false
    ///
    /// - returns:   处理后的字符串
    public func trim(_ trimNewline: Bool = false) ->String {
        if trimNewline {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    /// 去掉字符串前面的空格，根据参数确定是否过滤换行符
    ///
    /// - parameter trimNewline 是否过滤换行符，默认为false
    ///
    /// - returns:   处理后的字符串
//    public func trimLeft(_ trimNewline: Bool = false) ->String {
//        if self.isEmpty {
//            return self
//        }
//        
//        var index = self.startIndex
//        while index != self.endIndex {
//            let ch = self.characters[index]
//            if ch == Character(" ") {
//                index = .index(after: index)
//                continue
//            } else if ch == Character("\n") {
//                if trimNewline {
//                    index = .index(after: index)
//                    continue
//                } else {
//                    break
//                }
//            }
//            
//            break
//        }
//        
//        return self.substring(from: index)
//    }
    
    /// 去掉字符串后面的空格，根据参数确定是否过滤换行符
    ///
    /// - parameter trimNewline 是否过滤换行符，默认为false
    ///
    /// - returns:   处理后的字符串
//    public func trimRight(_ trimNewline: Bool = false) ->String {
//        if self.isEmpty {
//            return self
//        }
//        
//        var index = self.characters.index(before: self.endIndex)
//        while index != self.startIndex {
//            let ch = self.characters[index]
//            if ch == Character(" ") {
//                index = <#T##Collection corresponding to `index`##Collection#>.index(before: index)
//                continue
//            } else if ch == Character("\n") {
//                if trimNewline {
//                    index = <#T##Collection corresponding to `index`##Collection#>.index(before: index)
//                    continue
//                } else {
//                    index = <#T##Collection corresponding to `index`##Collection#>.index(after: index)
//                    break
//                }
//            }
//            
//            break
//        }
//        
//        return self.substring(to: index)
//    }
    
    // MARK: Substring API
    
    /// 获取子串的起始位置。
    ///
    /// - parameter substring 待查找的子字符串
    ///
    /// - returns:  如果找不到子串，返回NSNotFound，否则返回其所在起始位置
    public func location(_ substring: String) ->Int {
        return (self as NSString).range(of: substring).location
    }
    
    /// 根据起始位置和长度获取子串。
    ///
    /// - parameter location  获取子串的起始位置
    /// - parameter length    获取子串的长度
    ///
    /// - returns:  如果位置和长度都合理，则返回子串，否则返回nil
    public func substring(_ location: Int, length: Int) ->String? {
        if location < 0 && location >= self.length {
            return nil
        }
        
        if length <= 0 || length >= self.length {
            return nil
        }
        
        return (self as NSString).substring(with: NSMakeRange(location, length))
    }
    
    /// 根据下标获取对应的字符。若索引正确，返回对应的字符，否则返回nil
    ///
    /// - parameter index 索引位置
    ///
    /// - returns: 如果位置正确，返回对应的字符，否则返回nil
    public subscript(index: Int) ->Character? {
        get {
            if let str = substring(index, length: 1) {
                return Character(str)
            }
            
            return nil
        }
    }
    
    /// 判断字符串是否包含子串。
    ///
    /// - parameter substring 子串
    ///
    /// - returns:  如果找到，返回true,否则返回false
    public func isContain(_ substring: String) ->Bool {
        return (self as NSString).contains(substring)
    }
    
    // MARK: Alphanum API
    
    /// 判断字符串是否全是数字组成
    ///
    /// - returns:  若为全数字组成，返回true，否则返回false
    public func isOnlyNumbers() ->Bool {
        let set = CharacterSet.decimalDigits.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        let flag = range.location != NSNotFound
        return flag
    }
    
    /// 判断字符串是否全是字母组成
    ///
    /// - returns:  若为全字母组成，返回true，否则返回false
    public func isOnlyLetters() ->Bool {
        let set = CharacterSet.letters.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        
        return range.location != NSNotFound
    }
    
    /// 判断字符串是否全是字母和数字组成
    ///
    /// - returns:  若为全字母和数字组成，返回true，否则返回false
    public func isAlphanum() ->Bool {
        let set = CharacterSet.alphanumerics.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        
        return range.location != NSNotFound
    }
    
    // MARK: Validation API
    
    /// 判断字符串是否是有效的邮箱格式
    ///
    /// - returns:  若为有效的邮箱格式，返回true，否则返回false
    public func isValidEmail() ->Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        
        return predicate.evaluate(with: self)
    }
    
    // MARK: Format API
    
    /**
    
    插入字符分隔字符串
    - parameter char:     要插入的字符
    - parameter interval: 间隔数
    */
    public func insertCharByInterval(_ char: String, interval: Int) -> String {
        var text = self as NSString
        var newString = ""
        while (text.length > 0) {
            let subString = text.substring(to: min(text.length,interval))
            newString = newString + subString
            if (subString.length == interval) {
                newString = newString + char
            }
            text = text.substring(from: min(text.length,interval)) as NSString
        }
        return newString
    }
    
    // MARK: CAST TO OTHER TYPE API
    
    public func toDouble(_ def: Double = 0.0) -> Double {
        if !self.isEmpty {
            return Double(self)!
        } else {
            return def
        }
    }
    
    public func toFloat(_ def: Float = 0.0) -> Float {
        if !self.isEmpty {
            return Float(self)!
        } else {
            return def
        }
    }
    
    public func toInt(_ def: Int = 0) -> Int {
        if !self.isEmpty {
            return Int(self)!
        } else {
            return def
        }
    }
    
    public func toBool(_ def: Bool = false) -> Bool {
        if !self.isEmpty {
            let value = Int(self)!
            if value > 0 {
                return true
            } else {
                return false
            }
        } else {
            return def
        }
    }
    
    
    // 产生128位随机数
    
    public func get128BytesRandomNumbers() -> String {
        
        var array32 =  Array<String>()
        var array128 =  Array<String>()
        
        // 输出128位随机数
        for _ in 0...3 {
            
            // 输出32位随机数
            array32.removeAll()
            for _ in 0...31 {
                array32.append("\(arc4random() % 2)")
            }
            
            // 数组转字符串
            let strTwo = array32.joined(separator: "")
            //        print(strTwo)
            
            // 字符串转10进制
            let sixByte = binary2dec(num: strTwo)
            //        print(sixByte)
            
            // 10进制转16进制
            let sixStr = String(sixByte,radix:16)
            //        print(sixStr)
            
            let str = sixStr
            array128.append(str)
        }
        
        let str128 = array128.joined(separator: "")
        
        return str128

        
    }
    
    // 字符串转10进制
    func binary2dec(num:String) -> Int {
        var sum = 0
        for c in num.characters {
            sum = sum * 2 + Int("\(c)")!
        }
        return sum
    }

    
    
}

