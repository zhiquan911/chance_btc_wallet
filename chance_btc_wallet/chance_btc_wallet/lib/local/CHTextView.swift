//
//  CHTextView.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/26.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

@IBDesignable
class CHTextView: UITextView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    /**
     *  提示用户输入的标语
     */
    @IBInspectable var placeHolder: String = "" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /**
     *  标语文本的颜色
     */
    @IBInspectable var placeHolderColor: UIColor = UIColor.gray {
        didSet {
            self.setNeedsDisplay()
        }
        
    }
    
    // mark - Notifications
    
    @objc func didReceiveTextDidChangeNotification(notification: NSNotification) {
        self.setNeedsDisplay()
    }
    
    func setupUI() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveTextDidChangeNotification(notification:)),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self)
        
        self.placeHolderColor = UIColor.lightGray
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setupUI()
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.setupUI()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if (self.textStorage.length == 0) && self.placeHolder != "" {
            
            let placeHolderRect: CGRect = CGRect(x: 10.0, y: 7.0, width: rect.size.width, height: rect.size.height)
            
            self.placeHolderColor.set()
            
            let paragraphStyle = NSMutableParagraphStyle();
            paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;
            
            let textFontAttributes = [
                NSAttributedStringKey.font: self.font!,
                NSAttributedStringKey.foregroundColor: self.placeHolderColor,
                NSAttributedStringKey.paragraphStyle: paragraphStyle
                ]
            
            NSString(string: self.placeHolder).draw(
                in: placeHolderRect,
                withAttributes: textFontAttributes)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    
}

// MARK: - 为IB界面配置模拟数据
extension CHTextView {
    
    
    /// 模拟数据调试
    public override func prepareForInterfaceBuilder() {
//        self.placeHolder = "输入"
    }
}


