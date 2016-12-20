//
//  MultiSigTransaction.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/9.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 异常枚举
///
/// - decodeError: 解析错误
/// - encodeError: 编码错误
enum MultiSigError: Error {
    case decodeError
    case encodeError
}

/* 
 创建用于传输给其它人进行签名的多重签名交易表单
 协议格式：
 ################
 
 multisig:{"rawTx":"01000000021138...","redeemScriptHex":"532103324c4"...,"keySignatures":{"0":["3045022100...","304402..."],"2":["30450221...","3044022059bd..."]}}
 
 ################
 */
struct MultiSigTransaction {
    
    //多重签名专用标识头
    static let kPrefix = "multisig:"

    ///   - rawTx: 空白交易单（不包含签名数据）
    ///   - signatures: 签名数组，key的序号：输入单签名hex
    ///   - redeemScriptHex: 赎回脚本
    var rawTx: String = ""
    var keySignatures: [String: [String]]?
    var redeemScriptHex: String = ""
    
    
    /// 初始化对象
    ///
    /// - Parameters:
    ///   - rawTx: 空白交易单（不包含签名数据）
    ///   - signatures: 签名数组，key的序号：输入单签名hex
    ///   - redeemScriptHex: 赎回脚本
    init(rawTx: String,
        keySignatures: [String: [String]],
        redeemScriptHex: String) {
        self.rawTx = rawTx
        self.keySignatures = keySignatures
        self.redeemScriptHex = redeemScriptHex
    }

}


// MARK: - 支持JSON解析扩展
extension MultiSigTransaction {
    
    
    /// 解析表单结构体为json字符串
    //    数据格式-JSON TEXT
    //     {
    //        "rawTx":"01010101",
    //        "keySignatures":[
    //            "0":[
    //                "0101010101",
    //                "0101010101"
    //            ],
    //            "1":[
    //                "0101010101",
    //                "0101010101"
    //            ]
    //        ],
    //        "redeemScriptHex":"01010101"
    //     }
    var json: String {
        
        //没有签名返回空
        if keySignatures == nil {
            return ""
        }
        
        //添加无签名空白交易单
        var json: JSON = JSON(["rawTx": self.rawTx])
        
        //添加每个key的签名
        json["keySignatures"] = JSON(self.keySignatures!)
        
        //添加赎回脚本hex
        json["redeemScriptHex"] = JSON(self.redeemScriptHex)
        let text = MultiSigTransaction.kPrefix.appending(
            json.rawString(options: JSONSerialization.WritingOptions(rawValue: 0))!
        )
        return text
    }
    
    
    /// 通过json初始化多重签名交易表单
    ///
    /// - Parameter json: json字符串
    /// - Throws: 初始化异常
    init(json: String) throws {
        
        //1.检查头是否多重签名类型
        if !json.hasPrefix(MultiSigTransaction.kPrefix) {
            throw MultiSigError.decodeError
        }
        
        //2.除掉头部
        let contentText = json.substring(from:
            json.range(of: MultiSigTransaction.kPrefix)!.upperBound)
        //Log.debug("contentText = \(contentText)")
        
        //3.转为JSON对象
        guard let dataFromString = contentText.data(using: .utf8, allowLossyConversion: false)  else {
            throw MultiSigError.decodeError
        }
        
        let jsonData = JSON(data: dataFromString)
        
        //4.记录各个字段
        self.rawTx = jsonData["rawTx"].stringValue
        self.keySignatures = jsonData["keySignatures"].dictionaryObject as? [String: [String]]
        self.redeemScriptHex = jsonData["redeemScriptHex"].stringValue
        
    }
    
}
