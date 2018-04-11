//
//  CHLabelTextField.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/9.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

@objc
public protocol CHLabelTextFieldDelegate: AnyObject {
    
    @objc optional func textFieldShouldBeginEditing(_ ltf: CHLabelTextField) -> Bool // return NO to disallow editing.
    
    @objc optional func textFieldDidBeginEditing(_ ltf: CHLabelTextField) // became first responder
    
    @objc optional func textFieldShouldEndEditing(_ ltf: CHLabelTextField) -> Bool // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

    @objc optional func textFieldDidEndEditing(_ ltf: CHLabelTextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
//    @available(iOS 10.0, *)
//    @objc optional func textFieldDidEndEditing(_ ltf: CHLabelTextField, reason: UITextFieldDidEndEditingReason) // if implemented, called in place of textFieldDidEndEditing:
    
    @objc optional func textField(_ ltf: CHLabelTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool // return NO to not change text
    
    @objc optional func textFieldShouldClear(_ ltf: CHLabelTextField) -> Bool // called when clear button pressed. return NO to ignore (no notifications)

    @objc optional func textFieldShouldReturn(_ textField: CHLabelTextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    
}

@IBDesignable
public class CHLabelTextField: UIView {
    
    //MARK: - 成员变量
    public var labelTitle: UILabel?
    public var buttonAccessory: UIButton?
    public var textField: UITextField?
    public var buttonForText: UIButton?
    public var viewLine: UIView?
    
    
    /// 标签的文字
    @IBInspectable public var title: String = "-" {
        didSet {
            self.labelTitle?.text = self.title
            
        }
    }
    
    
    /// 标签文字颜色
    @IBInspectable public var titleColor: UIColor = UIColor(hex: 0x616161) {
        didSet {
            self.labelTitle?.textColor = self.titleColor
            
        }
    }
    
    
    /// 文本框预留填充
    @IBInspectable public var placeholder: String = "" {
        didSet {
            self.textField?.placeholder = self.placeholder
        }
    }
    
    /// 右边功能按钮图片
    @IBInspectable public var accessoryImage: UIImage? {
        didSet {
            if self.accessoryImage != nil {
                self.buttonAccessory?.setImage(self.accessoryImage, for: [.normal])
            } else {
                self.buttonAccessory?.setImage(nil, for: [.normal])
            }
            
        }
    }
    
    
    /// 右边功能按钮文字
    @IBInspectable public var accessoryTitle: String = "" {
        didSet {
            if !self.accessoryTitle.isEmpty {
                self.buttonAccessory?.setTitle(self.accessoryTitle, for: [.normal])
            } else {
                self.buttonAccessory?.setTitle("", for: [.normal])
            }
        }
        
    }
    
    /// 标签文字颜色
    @IBInspectable public var accessoryTitleColor: UIColor = UIColor.black {
        didSet {
            self.buttonAccessory?.setTitleColor(self.accessoryTitleColor, for: [.normal])
        }
    }
    
    
    /// 是否显示功能按钮
    @IBInspectable public var accessoryShow: Bool = true {
        didSet {
            self.buttonAccessory?.isHidden = !self.accessoryShow
            if self.accessoryShow {
                self.buttonAccessory?.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            } else {
                self.buttonAccessory?.widthAnchor.constraint(equalToConstant: 0).isActive = true
            }
        }
    }
    
    
    /// 输入框文本
    @IBInspectable public var text: String {
        set {
            self.textField?.text = newValue
            self.resizeFont()
        }
        
        get {
            return self.textField?.text ?? ""
        }
    }
    
    
    /// 代理委托
    @IBOutlet weak public var delegate: CHLabelTextFieldDelegate?
    
    
    /// 是否可以编辑
    @IBInspectable public var isEditable: Bool = true {
        didSet {
            //self.textField?.isEnabled = self.isEditable
            self.buttonForText?.isHidden = self.isEditable
        }
    }
    
    /// 点击功能按钮
    public typealias AccessoryPress = (CHLabelTextField) -> Void
    public var accessoryPress: AccessoryPress?
    
    /// 点击textField
    public typealias TextPress = (CHLabelTextField) -> Void
    public var textPress: TextPress?
    
    open func initUI() {
        
        /********* 初始化 *********/
        self.labelTitle = UILabel()
        self.labelTitle?.translatesAutoresizingMaskIntoConstraints = false
        self.labelTitle?.textColor = UIColor.lightGray
        self.labelTitle?.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelTitle?.textColor = UIColor(hex: 0x616161)
        self.labelTitle?.text = "label"
        self.addSubview(self.labelTitle!)
        
        self.textField = UITextField()
        self.textField?.translatesAutoresizingMaskIntoConstraints = false
        self.textField?.font = UIFont.systemFont(ofSize: 14)
        self.textField?.borderStyle = .none
        self.textField?.placeholder = "textField"
        self.textField?.textColor = UIColor(hex: 0x22CF7B)
        self.textField?.delegate = self
        self.addSubview(self.textField!)
        
        //透明按钮，用于textField的点击效果实现
        self.buttonForText = UIButton(type: .custom)
        self.buttonForText?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonForText?.setTitle("", for: .normal)
        self.buttonForText?.setTitleColor(UIColor.clear, for: .normal)
        self.buttonForText?.isHidden = self.isEditable  //文本框可编辑就把它隐藏
        self.buttonForText?.backgroundColor = UIColor.clear
        self.addSubview(self.buttonForText!)
        
        //功能按钮
        self.buttonAccessory = UIButton(type: .custom)
        self.buttonAccessory?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonAccessory?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.buttonAccessory?.setTitleColor(UIColor.black, for: .normal)
        self.addSubview(self.buttonAccessory!)
        
        self.viewLine = UIView()
        self.viewLine?.translatesAutoresizingMaskIntoConstraints = false
        self.viewLine?.backgroundColor = UIColor(hex: 0xDBDBDB)
        self.addSubview(self.viewLine!)
        
        //添加按钮点击方法
        self.buttonAccessory?.addTarget(self, action: #selector(self.handleAccessoryButtonPress), for: .touchUpInside)
        self.buttonForText?.addTarget(self, action: #selector(self.handleTextFieldPress), for: .touchUpInside)

    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
        self.layoutUI()
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        //为何要在awakeFromNib再执行布局，因为awakeFromNib之后就可以得到真正的设备尺寸。
        //init?(coder aDecoder: NSCoder)时，还未得到真正的设备尺寸。
        self.layoutUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.resizeFont()
    }
}


// MARK: - 内部方法
extension CHLabelTextField {
    
    
    /// 布局设置
    func layoutUI() {
        
        
        
        /********* 约束布局 *********/
        
        let views: [String : Any] = [
            "labelTitle": self.labelTitle!,
            "textField": self.textField!,
            "viewLine": self.viewLine!,
            "buttonAccessory": self.buttonAccessory!,
            "buttonForText": self.buttonForText!
        ]
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[labelTitle]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[viewLine]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-4-[labelTitle(21)]-4-[textField(==30)]-4-[viewLine(0.5)]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[textField]-8-[buttonAccessory(>=0)]-0-|",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[buttonForText(==textField)]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[labelTitle]-4-[buttonForText(==textField)]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        //buttonAccessory的宽度压缩优先，这样buttonAccessory不需要写死宽度，当它宽度变长，textField就会缩短
        self.buttonAccessory?.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        
    }
    
    
    /// 重新计算字体大小
    func resizeFont() {
        if !self.isEditable {
            let size = self.text.textSizeWithFont(UIFont.systemFont(ofSize: 14), constrainedToSize: CGSize(width: self.bounds.width, height: bounds.height))
            if size.width >= self.textField!.width {
                self.textField?.font = UIFont.systemFont(ofSize: 11)
            } else {
                self.textField?.font = UIFont.systemFont(ofSize: 14)
            }
        }
    }
    
    /// 点击功能力按钮
    @objc public func handleAccessoryButtonPress() {
        //Log.debug("handleAccessoryButtonPress")
        self.accessoryPress?(self)
    }
    
    /// 点击TextField
    @objc public func handleTextFieldPress() {
        //Log.debug("handleTextFieldPress")
        self.textPress?(self)
    }
    
    
}


// MARK: - 实现UITextField委托方法
extension CHLabelTextField: UITextFieldDelegate {
    
    
    /// 是否可以编辑
    ///
    /// - Parameter textField: 输入框
    /// - Returns: 是否可以编辑
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard self.isEditable else {
            return false
        }
        
        guard let flag = self.delegate?.textFieldShouldBeginEditing?(self) else {
            return self.isEditable
        }
        
        return flag
    }

    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidBeginEditing?(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldEndEditing?(self) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidEndEditing?(self)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        self.delegate?.textFieldDidEndEditing?(self)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldClear?(self) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldReturn?(self) ?? true
    }
}
