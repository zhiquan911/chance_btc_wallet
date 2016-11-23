//
//  RemoteService.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/20.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


/// 远端节点协议
protocol RemoteService {
    
    var apiUrl: String { get }

    /**
     获取账户余额接口
     */
    func userBalance(address: String, callback: @escaping (MessageModule, UserBalance) -> Void)
    
    /**
     获取账户交易数据列表接口
     */
    func userTransactions(address: String, from: String, to: String, limit: String,
        callback: @escaping (MessageModule, [UserTransaction], PageModule?) -> Void)
    
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
                         parameters: [String: Any], useCache: Bool = false,
                         response: @escaping (_ json: JSON, _ isCache: Bool) -> Void) {
        
        Log.debug("接口地址: \(url)")
        Log.debug("传入参数: \(parameters)")
        
        Alamofire.request(url, method: method, parameters: parameters)
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
    }
    
}
