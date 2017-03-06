//
//  RemoteService.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/20.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

/// 远端节点枚举
enum BlockchainNode: String {
    
    //https://blockchain.info/
    case blockchain_info = "blockchain.info"
    
    //https://insight.bitpay.com
    case insight_bitpay = "insight.bitpay.com"
    
    //服务实例
    var service: RemoteService {
        switch self {
        case .blockchain_info:
            return BlockchainRemoteService.sharedInstance
        case .insight_bitpay:
            return InsightRemoteService.sharedInstance
        }
    }
    
    //节点名字
    var name: String {
        switch self {
        case .blockchain_info:
            return "blockchain.info"
        case .insight_bitpay:
            return "insight.bitpay"
        }
    }
    
    //节点域名
    var url: String {
        switch self {
        case .blockchain_info:
            return "https://blockchain.info/"
        case .insight_bitpay:
            return "https://insight.bitpay.com/"
        }
    }
    
    
    /// 余额是否包含在交易中
    var isBalanceInTransactions: Bool {
        switch self {
        case .blockchain_info:
            return true
        default:
            return false
        }

    }
    
    //所有节点数组
    static var allNodes: [BlockchainNode] {
        return [
            BlockchainNode.blockchain_info,
            BlockchainNode.insight_bitpay
        ]
    }
    
}

///
/// 接口返回数据类型
///
/// - string: 字符串
/// - json: json
/// - bytes: 字节流
enum ResponseDataType {
    
    case string
    case json
    case bytes
}

/// 远端节点协议
protocol RemoteService {
    
    var apiUrl: String { get }

    /**
     获取账户余额接口
     */
    func userBalance(address: String, callback: @escaping (MessageModule, UserBalance) -> Void)
    
    /**
     获取账户交易数据列表接口
     UserBalance,blockchain.info的接口可以返回用户余额。
     */
    func userTransactions(address: String, from: String, to: String, limit: String,
        callback: @escaping (MessageModule, String, UserBalance?, [UserTransaction], PageModule?) -> Void)
    
    /**
     获取用户未花交易记录
     
     - parameter address:
     - parameter callback:
     */
    func userUnspentTransactions(address: String,
        callback: @escaping (MessageModule, [UnspentTransaction]) -> Void)
    
    /**
     广播交易信息
     
     - parameter transactionHexString: 交易数据16进制字节流
     - parameter callback: 返回交易id
     */
    func sendTransaction(transactionHexString: String, callback: @escaping (MessageModule, String) -> Void)
}


// MARK: - 实现HTTP请求
extension RemoteService {
    
    /**
     调用http接口
     
     - parameter url:        接口地址
     - parameter parameters: 传入参数
     - parameter response:   回调处理
     */
    func sendJsonRequest(_ url: String,method: Alamofire.HTTPMethod = .post,
                         parameters: [String: Any],
                         useCache: Bool = false,
                         encoding: ParameterEncoding = URLEncoding.default,
                         responseDataType: ResponseDataType = .json,
                         response: @escaping (_ json: JSON, _ isCache: Bool) -> Void) {
        
        Log.debug("接口地址: \(url)")
        Log.debug("传入参数: \(parameters)")
        
        //返回数据类型
        switch responseDataType {
        case .string:
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding)
                .responseString {
                    resp in
                    let result = resp.result
                    if result.isSuccess {
                        var json: JSON = ["resMsg": ["message": "success", "code": "\(ApiResultCode.Success.rawValue)"]]
                        json["datas"] = JSON(result.value!)
                        Log.debug("接口返回: \(json)")
                        //返回json对象
                        response(json, false)
                        
                    } else {
                        Log.debug("接口返回: \(result.error)")
                        let json: JSON =  ["resMsg": ["message": "server request error", "code": "90000"]]
                        //返回json对象
                        response(json, false)
                    }
            }
        case .json:
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding)
                .responseJSON {
                    resp in
                    let result = resp.result
                    if result.isSuccess {
                        var json: JSON = ["resMsg": ["message": "success", "code": "\(ApiResultCode.Success.rawValue)"]]
                        json["datas"] = JSON(result.value!)
                        Log.debug("接口返回: \(json)")
                        //返回json对象
                        response(json, false)
                        
                    } else {
                        Log.debug("接口返回: \(result.error)")
                        let json: JSON =  ["resMsg": ["message": "server request error", "code": "90000"]]
                        //返回json对象
                        response(json, false)
                    }
            }
        default:break
            
        }
        
    }
    
}
