//
//  Constants.swift
//  light_guide
//  全局常数类
//  Created by Chance on 15/8/29.
//  Copyright (c) 2015年 wetasty. All rights reserved.
//

import Foundation
import UIKit

///MARK: - 结构体

struct CHWalletsKeys {
    
    static let prefix = ""  //前续头
    
    /** 钱包设置类 **/
    static let UserNickname = prefix + "btc_user_nickname"              //用户昵称
    static let BTCAddress = prefix + "btc_address"                  //用户地址
    static let BTCRedeemScript = prefix + "btc_redeem_script"       //用户赎回脚本
    static let BTCSecretPhrase = prefix + "btc_secret_phrase"       //用户恢复密语
    static let BTCWalletSeed = prefix + "btc_wallet_seed"         //钱包种子
    static let BTCPrivateKey = prefix + "btc_private_key"           //用户私钥
    static let BTCPubkey = prefix + "btc_pubkey"                    //用户公钥
    static let BTCExtendedPrivateKey = prefix + "btc_extended_private_key"           //用户私钥
    static let BTCExtendedPubkey = prefix + "btc_extended_pubkey"                    //用户公钥
    static let BTCWalletPassword = prefix + "btc_wallet_password"           //用户密码
    static let BTCWalletAccountsCount = prefix + "btc_wallet_account_count"           //钱包账户个数
    static let BTCWalletAccountsJSON = prefix + "btc_wallet_accounts_json"           //钱包账户地址的json数组
    
    /** 系统设置类 **/
    static let EnableTouchID = prefix + "enable_touchid"           //是否开启指纹验证
    static let SelectedAccount = prefix + "selected_account"           //选择的账户地址
    static let SelectedBlockchainNode = prefix + "selected_blockchain_node"           //选择的云节点
    static let EnableICloud = prefix + "enable_icloud"         //是否开启icloud自动同步
}

/// 系统版本号
let kIOSVersion : NSString? = UIDevice.current.systemVersion as NSString?

/**
 *  确认是否
 */
public enum Confirm: String {
    case NO = "0"
    case YES = "1"
}

/**
 API返回结果代码
 */
public enum ApiResultCode: String {
    
    /**
     *  操作成功（success）
     */
    case Success = "1000"
    
    /**
     *  需求继续签名
     */
    case NeedOtherSignature = "1101"
    
    /**
     *  一般错误提示（Error Tips）
     */
    case ErrorTips = "1001"
    
    /**
     *  内部错误（Internal Error）
     */
    case InternalError = "1002"
    
    /**
     *  应用授权失败（Auth No Pass）
     */
    case AuthNoPass = "1003"
    
    /**
     *  token失效（Token No Pass）
     */
    case TokenNoPass = "1004"
    
    /**
     *  接口访问失败（APIResponseError）
     */
    case APIResponseError = "90000"
    
    
}

/**
 货币种类
 
 - BTC: 比特币
 - LTC: 莱特币
 - CNY: 人民币
 */
public enum CurrencyType: String {
    /**
     *  比特币
     */
    case BTC = "BTC"
    
    /**
     *  莱特币
     */
    case LTC = "LTC"
    
    /**
     *  人民币
     */
    case CNY = "CNY"
    
    /**
     *  美元
     */
    case USD = "USD"
    
    /// 货币标识
    var symbol: String {
        var s = ""
        switch self {
        case .CNY:
            s = "￥"
        case .USD:
            s = "$"
        case .BTC:
            s = "฿"
        case .LTC:
            s = "Ł"
        }
        return s
    }
    
    /**
     返回类型名称
     
     - returns: 返回类型名称
     */
    func coinName() -> String {
        switch self {
        case .BTC:
            return NSLocalizedString("BTC", comment: "比特币")
        case .LTC:
            return NSLocalizedString("LTC", comment: "比特币")
        case .CNY:
            return NSLocalizedString("CNY", comment: "人民币")
        case .USD:
            return NSLocalizedString("USD", comment: "美元")
        }
    }
    
    
    /// 地址前缀
    var addressPrefix: String {
        switch self {
        case .BTC:
            return "bitcoin:"
        case .LTC:
            return "litecoin:"
        case .CNY:
            return ""
        case .USD:
            return ""
        }
    }
}

/**
 多签脚本
 
 - PrivateKey:   私钥
 - PublicKey:    公钥
 - RedeemScript: 多重签名赎回脚本
 */
public enum ExportKeyType: String {
    case PrivateKey = "1"
    case PublicKey = "2"
    case RedeemScript = "3"
}


/**
 账户类型
 
 - Normal:   单签HD
 - MultiSig: 多签账户
 */
public enum CHAccountType: String {
    case normal = "1"
    case multiSig = "2"
    
    
    /// 账户类型名
    var typeName: String {
        switch self {
        case .normal:
            return "Normal".localized()
        case .multiSig:
            return "Multi-Sig".localized()
        }
    }
    
    
    /// 卡片背景色
    var cardBGColor: UIColor {
        switch self {
        case .normal:
            return UIColor(hex: 0x1E74CA)
        case .multiSig:
            return UIColor(hex: 0x7956B6)
        }
    }
}


/**
 传输类型
 
 - Request:  发送
 - Response: 返回
 */
public enum WSDataType: String {
    case Request = "1"		//发送
    case Response = "2"     //返回
}

/**
 *  语言
 */
enum Language {
    
    case english
    case chinese_Simple
    
    //短字
    var shortName: String {
        switch self {
        case .english:
            return "en"
        case .chinese_Simple:
            return "cn"
        }
    }
    
    /// 语言类型
    var langType: String {
        switch self {
        case .english:
            return "2"
        case .chinese_Simple:
            return "1"
        }
    }
    
}


/**
 故事板资源
 
 - main:
 - welcome:
 - wallet:
 - setting:
 */
enum StoryBoard {
    
    case main
    case welcome
    case wallet
    case setting
    case account
    
    /// board实体
    var board: UIStoryboard {
        switch self {
        case .main:
            return UIStoryboard.init(name: "Main", bundle: nil)
        case .welcome:
            return UIStoryboard.init(name: "Welcome", bundle: nil)
        case .wallet:
            return UIStoryboard.init(name: "Wallet", bundle: nil)
        case .setting:
            return UIStoryboard.init(name: "Setting", bundle: nil)
        case .account:
            return UIStoryboard.init(name: "Account", bundle: nil)
        }
        
    }
    
    
    /// 初始界面
    ///
    /// - Parameter type:   类
    func initView<T : UIViewController>(type: T.Type) -> T? {
        let fullName: String = String(describing: type)
        let vc = self.board.instantiateViewController(withIdentifier: fullName)
        return vc as? T
    }
    
    /// 初始界面
    ///
    /// - Parameter name:   id名字
    func initView(name: String) -> UIViewController? {
        let vc = self.board.instantiateViewController(withIdentifier: name)
        return vc
    }
}
