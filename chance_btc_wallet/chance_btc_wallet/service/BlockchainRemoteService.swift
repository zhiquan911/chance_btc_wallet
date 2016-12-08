//
//  BlockchainRemoteService.swift
//  Chance_wallet
//
//  Created by Chance on 16/3/1.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BlockchainRemoteService: RemoteService {
    
    var apiUrl = "https://blockchain.info/";
    
    /// 全局唯一实例
    static let sharedInstance: BlockchainRemoteService = {
        let instance = BlockchainRemoteService()
        return instance
    }()
    
    
    //MARK: - 重载标准的接口方法
    
    func userBalance(address: String, callback: @escaping (MessageModule, UserBalance) -> Void) {
        
        let params = [
            "address": address
        ]
        
        var url = apiUrl + "rawaddr"
        url.append("/\(address)")
        
        self.sendJsonRequest(url, method: .get, parameters: params) {
            (json, isCache) -> Void in
            let message = MessageModule(json: json["resMsg"])
            let data = json["datas"]
            let userBalance = UserBalance()
            if data.exists() {
                //                "addrStr": "16VvieA7tLFZx5aRb5q8bJTZuV378A8pWv",
                //                "balance": 0,
                //                "balanceSat": 0,
                //                "totalReceived": 0.0726,
                //                "totalReceivedSat": 7260000,
                //                "totalSent": 0.0726,
                //                "totalSentSat": 7260000,
                //                "unconfirmedBalance": 0,
                //                "unconfirmedBalanceSat": 0,
                //                "unconfirmedTxApperances": 0,
                //                "txApperances": 9,
                userBalance.address = data["address"].stringValue
                userBalance.balanceSat = data["final_balance"].intValue
                userBalance.totalReceivedSat = data["total_received"].intValue
                userBalance.totalSentSat = data["total_sent"].intValue
                userBalance.txApperances = data["n_tx"].intValue
            }
            callback(message, userBalance)
        }
    }
    
    func userTransactions(address: String, from: String, to: String, limit: String, callback: @escaping (MessageModule, [UserTransaction], PageModule?) -> Void) {
        let params = [
            "address": address
        ]
        
        var url = apiUrl + "rawaddr"
        url.append("/\(address)?offset=\(from)&limit=\(limit)")
        
        self.sendJsonRequest(url, method: .get, parameters: params) {
            (json, isCache) -> Void in
            let message = MessageModule(json: json["resMsg"])
            let data = json["datas"]
            var userTransactions = [UserTransaction]()
            if data.exists() {
                let items = data["txs"].arrayValue
                for dic in items {
//                    "ver":1,
//                    "inputs":[
//                    {
//                    "sequence":4294967295,
//                    "prev_out":{
//                    "spent":true,
//                    "tx_index":129980108,
//                    "type":0,
//                    "addr":"1HvgRTi2CmaSHUkfWUCAqkYjF7AiBohzbB",
//                    "value":10000,
//                    "n":0,
//                    "script":"76a914b9a8f753a620aa27836db34e28a3582cbd25c71588ac"
//                    },
//                    "script":"483045022100a260961b93d3b283ef76c161a81f30911ee313dfadd10fe455bcdaf65c42107602204f6824ac4e95c3b2a81de493e0e7521a1af202e2bcaa22b44b5a3fb0b4e2cf6c012103306e60b8c65a7b1338ae632a9b78fd627477dcc8e4d02a547df034a974144fe9"
//                    },
//                    {
//                    "sequence":4294967295,
//                    "prev_out":{
//                    "spent":true,
//                    "tx_index":129817786,
//                    "type":0,
//                    "addr":"1HvgRTi2CmaSHUkfWUCAqkYjF7AiBohzbB",
//                    "value":10000,
//                    "n":0,
//                    "script":"76a914b9a8f753a620aa27836db34e28a3582cbd25c71588ac"
//                    },
//                    "script":"473044022068c10112ae2dd16ea02a0930df17456e3fec05f28b77d5912723850d9a1c2b16022075ceff91b598a70785f33f39953cde5336c0d6693b8a5059f9dc0e2e88adf82e012103306e60b8c65a7b1338ae632a9b78fd627477dcc8e4d02a547df034a974144fe9"
//                    },
//                    {
//                    "sequence":4294967295,
//                    "prev_out":{
//                    "spent":true,
//                    "tx_index":129816887,
//                    "type":0,
//                    "addr":"1HvgRTi2CmaSHUkfWUCAqkYjF7AiBohzbB",
//                    "value":10000,
//                    "n":0,
//                    "script":"76a914b9a8f753a620aa27836db34e28a3582cbd25c71588ac"
//                    },
//                    "script":"483045022100b9b000e11ce3b2641084f277c1837694ae30384ca99a4eaaf4cd986025dae373022007cfd399c5271d1f37331dc238cb72247b4191c56cd131971c29eae8c0bf65f1012103306e60b8c65a7b1338ae632a9b78fd627477dcc8e4d02a547df034a974144fe9"
//                    }
//                    ],
//
//                    "out":[
//                    {
//                    "spent":true,
//                    "tx_index":129980308,
//                    "type":0,
//                    "addr":"1L8WssQRCrDKRSF5MwUb2E4HhGzkVTP93U",
//                    "value":20000,
//                    "n":0,
//                    "script":"76a914d1d63de21e37c2845b9c134edd02a74881a53d1e88ac"
//                    }
//                    ],
//                    "lock_time":0,
//                    "result":0,
//                    "size":487,
//                    "time":1455932732,
//                    "tx_index":129980308,
//                    "vin_sz":3,
//                    "hash":"d756d527db180e646189daf667dfca4d3127607fb790c2542652d9809816b23e",
//                    "vout_sz":1
//                    "block_height":399242,
//                    "relayed_by":"37.205.10.140",
                    
                    let tx = UserTransaction()
                    tx.txid = dic["hash"].stringValue
                    tx.version = dic["ver"].intValue
                    tx.locktime = dic["lock_time"].intValue
                    tx.blockHeight = dic["block_height"].intValue
                    if tx.blockHeight > 0 {
                        tx.confirmations = 1
                    } else {
                        tx.confirmations = 0
                    }
                    tx.blocktime = dic["time"].intValue
                    tx.size = dic["size"].intValue
                    
                    //封装交易输入输出的单元
                    let vins = dic["inputs"].arrayValue
                    for vin in vins {
                        let txin = TransactionUnit()
                        txin.address = vin["prev_out"]["addr"].stringValue
                        txin.value = BTCAmount(vin["prev_out"]["value"].intValue)
                        tx.vinTxs.append(txin)
                    }
                    
                    let vouts = dic["out"].arrayValue
                    for vout in vouts {
                        let txout = TransactionUnit()
                        txout.address = vout["addr"].stringValue
                        txout.value = BTCAmount(vout["value"].intValue)
                        tx.voutTxs.append(txout)
                    }
                    
                    userTransactions.append(tx)
                }
            }
            callback(message, userTransactions, nil)
        }
    }
    
    /**
     获取用户未花交易记录
     
     - parameter address:
     - parameter callback:
     */
    func userUnspentTransactions(address: String,
        callback: @escaping (MessageModule, [UnspentTransaction]) -> Void) {
            let params = [
                "active": address
            ]
            
            let url = apiUrl + "unspent"
            
            self.sendJsonRequest(url, parameters: params) {
                (json, isCache) -> Void in
                let message = MessageModule(json: json["resMsg"])
                let data = json["datas"]
                let items = data["unspent_outputs"].arrayValue
                var unspentUserTransactions = [UnspentTransaction]()
                for dic in items {
//                    "tx_hash":"0387d2b856a4e4d69ceb8b73e13d5d03a44419b19f00ee7b30f8afbf57df033f",
//                    "tx_hash_big_endian":"3f03df57bfaff8307bee009fb11944a4035d3de1738beb9cd6e4a456b8d28703",
//                    "tx_index":132619844,
//                    "tx_output_n": 1,
//                    "script":"76a914b9a8f753a620aa27836db34e28a3582cbd25c71588ac",
//                    "value": 90000,
//                    "value_hex": "015f90",
//                    "confirmations":0
                    
                    let tx = UnspentTransaction()
                    tx.txid = dic["tx_hash_big_endian"].stringValue
//                    tx.address = dic["address"].stringValue
                    tx.vout = dic["tx_output_n"].intValue
                    tx.timestamp = dic["ts"].intValue
                    tx.confirmations = dic["confirmations"].intValue
                    tx.scriptPubKey = dic["script"].stringValue
                    tx.amount = BTCAmount(dic["value"].intValue)
                    
                    unspentUserTransactions.append(tx)
                }
                
                callback(message, unspentUserTransactions)
            }
    }
    
    
    /**
     广播交易信息
     
     - parameter transactionHexString: 交易数据16进制字节流
     - parameter callback: 返回交易id
     */
    func sendTransaction(transactionHexString: String, callback: @escaping (MessageModule, String) -> Void) {
        let params = [
            "tx": transactionHexString
        ]
        
        let url = apiUrl + "pushtx"
        
        self.sendJsonRequest(url, parameters: params, responseDataType: .string) {
            (json, isCache) -> Void in
            let message: MessageModule
            let data = json["datas"]
            if let result = data.rawString(), result == "Transaction Submitted\n" {
                message = MessageModule(
                    code: "\(ApiResultCode.Success.rawValue)",
                    message: "success")
            } else {
                message = MessageModule(
                    code: "\(ApiResultCode.ErrorTips.rawValue)",
                    message: json.rawString()!)
            }
            
            callback(message, "")
        }
    }
    
}
