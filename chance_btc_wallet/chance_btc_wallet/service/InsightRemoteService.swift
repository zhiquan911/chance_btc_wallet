//
//  InsightRemoteService.swift
//  bitbank_wallet
//
//  Created by 麦志泉 on 16/1/20.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InsightRemoteService: RemoteService {
    
    var apiUrl = "https://insight.bitpay.com/api/"
    
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
        
        var url = apiUrl + "addr"
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
                userBalance.address = data["addrStr"].stringValue
                userBalance.balance = data["balance"].doubleValue
                userBalance.balanceSat = data["balanceSat"].intValue
                userBalance.totalReceived = data["totalReceived"].doubleValue
                userBalance.totalReceivedSat = data["totalReceivedSat"].intValue
                userBalance.totalSent = data["totalSent"].doubleValue
                userBalance.totalSentSat = data["totalSentSat"].intValue
                userBalance.unconfirmedBalance = data["unconfirmedBalance"].doubleValue
                userBalance.unconfirmedBalanceSat = data["unconfirmedBalanceSat"].intValue
                userBalance.unconfirmedTxApperances = data["unconfirmedTxApperances"].intValue
                userBalance.txApperances = data["txApperances"].intValue
            }
            callback(message, userBalance)
        }
    }
    
    func userTransactions(address: String, from: String, to: String, limit: String, callback: @escaping (MessageModule, [UserTransaction], PageModule?) -> Void) {
        let params = [
            "addrs": address,
            "from": from,
            "to": to
        ]
        
        let url = apiUrl + "addrs/txs"
        
        self.sendJsonRequest(url, parameters: params) {
            (json, isCache) -> Void in
            let message = MessageModule(json: json["resMsg"])
            let data = json["datas"]
            var userTransactions = [UserTransaction]()
            if data.exists() {
                let items = data["items"].arrayValue
                for dic in items {
                    //                    txid: '3e81723d069b12983b2ef694c9782d32fca26cc978de744acbc32c3d3496e915',
                    //                    version: 1,
                    //                    locktime: 0,
                    //                    vin: [Object],
                    //                    vout: [Object],
                    //                    blockhash: '00000000011a135e5277f5493c52c66829792392632b8b65429cf07ad3c47a6c',
                    //                    confirmations: 109367,
                    //                    time: 1393659685,
                    //                    blocktime: 1393659685,
                    //                    valueOut: 0.3453,
                    //                    size: 225,
                    //                    firstSeenTs: undefined,
                    //                    valueIn: 0.3454,
                    //                    fees: 0.0001
                    
                    let tx = UserTransaction()
                    tx.txid = dic["txid"].stringValue
                    tx.version = dic["version"].intValue
                    tx.locktime = dic["locktime"].intValue
                    tx.blockhash = dic["blockhash"].stringValue
                    tx.confirmations = dic["confirmations"].intValue
                    tx.timestamp = dic["time"].intValue
                    tx.blocktime = dic["blocktime"].intValue
                    tx.valueOut = dic["valueOut"].doubleValue
                    tx.size = dic["size"].intValue
                    tx.valueIn = dic["valueIn"].doubleValue
                    tx.fees = dic["fees"].doubleValue
                    
                    //封装交易输入输出的单元
                    let vins = dic["vin"].arrayValue
                    for vin in vins {
                        let txin = TransactionUnit()
                        txin.address = vin["addr"].stringValue
                        txin.value = BTCAmount.satoshiWithStringInBTCFormat(vin["value"].stringValue)
                        tx.vinTxs.append(txin)
                    }
                    
                    let vouts = dic["vout"].arrayValue
                    for vout in vouts {
                        let txout = TransactionUnit()
                        txout.address = vout["scriptPubKey"]["addresses"][0].stringValue
                        txout.value = BTCAmount.satoshiWithStringInBTCFormat(vout["value"].stringValue)
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
                "addrs": address
            ]
            
            let url = apiUrl + "addrs/utxo"
            
            self.sendJsonRequest(url, parameters: params) {
                (json, isCache) -> Void in
                let message = MessageModule(json: json["resMsg"])
                let data = json["datas"].arrayValue
                var unspentUserTransactions = [UnspentTransaction]()
                for dic in data {
                    //                    "address": "1DjCy5rn1rq64EWMjF16a4Gb9M34MFj3CF",
                    //                    "txid": "95d44ac1d829e3e81ab80186d6e5ceabb346f9a4c844f646f7c1697496143099",
                    //                    "vout": 0,
                    //                    "ts": 1453702846,
                    //                    "scriptPubKey": "76a9148b9cf82525633537e68e34f9dca7ff20d9a020ad88ac",
                    //                    "amount": 0.1635,
                    //                    "confirmations": 6,
                    //                    "confirmationsFromCache": true
                    
                    let tx = UnspentTransaction()
                    tx.txid = dic["txid"].stringValue
                    tx.address = dic["address"].stringValue
                    tx.vout = dic["vout"].intValue
                    tx.timestamp = dic["ts"].intValue
                    tx.confirmations = dic["confirmations"].intValue
                    tx.scriptPubKey = dic["scriptPubKey"].stringValue
                    tx.amount = BTCAmount.satoshiWithStringInBTCFormat(
                        String(format: "%.9f", dic["amount"].doubleValue))
                    tx.confirmationsFromCache = dic["confirmationsFromCache"].boolValue
                    
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
            "rawtx": transactionHexString
        ]
        
        let url = apiUrl + "tx/send"
        
        self.sendJsonRequest(url, parameters: params) {
            (json, isCache) -> Void in
            let message = MessageModule(json: json["resMsg"])
            let data = json["datas"]
            let txid = data["txid"].stringValue
            
            callback(message, txid)
        }
    }
}
