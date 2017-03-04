//
//  AccountCardPageCell.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/2.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit

class AccountCardPageCell: UICollectionViewCell {
    
    //MARK: - 成员变量
    
    @IBOutlet var labelNickname: UILabel!
    @IBOutlet var labelBalanceValue: UILabel!
    @IBOutlet var labelBalanceUnit: UILabel!
    @IBOutlet var labelMoneyValue: UILabel!
    @IBOutlet var labelMoneyUnit: UILabel!
    @IBOutlet var imageViewCurrencyIcon: UIImageView!
    @IBOutlet var imageViewQRCode: UIImageView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var viewAddress: UIView!
    
    typealias AddressPress =
        (_ cell: AccountCardPageCell) -> Void
    var addressPress: AddressPress?
    
    typealias QRCodePress =
        (_ cell: AccountCardPageCell) -> Void
    var qrCodePress: QRCodePress?

    class var cellIdentifier: String{
        
        return "AccountCardPageCell"
    }
    
    //MARK: - 重载方法
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //UICollectionViewCell配置圆角阴影方法
        //http://qingqinghebiancao.github.io/2016/01/12/iOS开发小技巧/
        
        // 将阴影加在cell上
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        //将圆角加在cell的ContentView上
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        
        //地址背景圆角
        self.viewAddress.layer.cornerRadius = 2
        self.viewAddress.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //在执行layoutSubviews才渲染阴影路径，因为layoutSubviews里才能获取self.bounds的正确值
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
    }

}


// MARK: - 配置用户和余额内容
extension AccountCardPageCell {
    
    
    /// 配置单元格元素
    ///
    /// - Parameters:
    ///   - account: 账户
    ///   - userBalance: 余额
    ///   - currencyType: 余额的货币种类
    ///   - exCurrencyType: 换算的法币种类
    func configAccountCell(account: CHBTCAcount,
                           userBalance: UserBalance?,
                           currencyType: CurrencyType,
                           exCurrencyType: CurrencyType) {
  
        self.labelNickname.text = account.userNickname
        self.labelAddress.text = account.address.string
        self.labelBalanceUnit.text = currencyType.rawValue
        self.labelMoneyUnit.text = exCurrencyType.rawValue
        
        //地址二维码
        if let qrcode = account.qrCode {
            self.imageViewQRCode.image = qrcode
        } else {
            account.qrCode = QRCode.generateImage(
                currencyType.addressPrefix + account.address.string,
                avatarImage: nil,
                color: CIColor(color: UIColor.white),
                backColor: CIColor(color: UIColor.clear))
            
            self.imageViewQRCode.image = account.qrCode
        }
        
        //余额数据和账户地址相匹配才更新
        if let ub = userBalance, ub.address == account.address.string {
            
            self.labelBalanceValue.text = (userBalance!.balanceSat + userBalance!.unconfirmedBalanceSat).toString()
            self.labelMoneyValue.text = userBalance?.getLegalMoney(price: 9000).toString(maxF: 2)
            
            self.labelBalanceValue.textColor = UIColor.white
            self.labelMoneyValue.textColor = UIColor.white
            
        } else {
            //计算中
            self.labelBalanceValue.text = "Calculating...".localized()
            self.labelMoneyValue.text = "Calculating...".localized()
            
            self.labelBalanceValue.textColor = UIColor(hex: 0x49c686)
            self.labelMoneyValue.textColor = UIColor(hex: 0x49c686)
        }
    }
    
    
    /// 点击地址
    ///
    /// - Parameter sender:
    @IBAction func handleAddressPress(sender: AnyObject?) {
        self.addressPress?(self)
    }
    
    
    /// 点击二维码
    ///
    /// - Parameter sender: 
    @IBAction func handleQRCodePress(sender: AnyObject?) {
        self.qrCodePress?(self)
    }
}
