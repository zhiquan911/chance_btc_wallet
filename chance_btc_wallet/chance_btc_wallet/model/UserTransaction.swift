//
//  UserTransaction.swift
//  Chance_wallet
//
//  Created by Chance on 16/1/20.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit


/// 交易类型
///
/// - send: 发送
/// - receive:  接收
enum TransactionInOut {
    case send
    case receive
    
    
    /// 图片标识
    var image: UIImage {
        switch self {
        case .send:
            return UIImage(named: "icon_tx_cell_send")!
        case .receive:
            return UIImage(named: "icon_tx_cell_received")!
        }
    }
    
    
    /// 符号表示
    var symbol: String {
        switch self {
        case .send:
            return "-"
        case .receive:
            return "+"
        }
    }
    
    
    /// 来自或发去
    var fromOrTo: String {
        switch self {
        case .send:
            return "to：".localized()
        case .receive:
            return "from：".localized()
        }
    }
    
    
    /// 颜色标识
    var color: UIColor {
        switch self {
        case .send:
            return UIColor(hex: 0xFA291B)
        case .receive:
            return UIColor(hex: 0x23BE72)
        }
    }
}

class UserTransaction: NSObject {

    /*
    "txid": "4bd2a1f9c1bf324666b523bc7d4924df34bbe0dfceb3139a3eab40a55e5ce0ff",
    "version": 1,
    "locktime": 0,
    "vin": [
    {
    "txid": "4ce62ef56b5e032501192169186823da374ed2969b5e8367e9135692062f989b",
    "vout": 1,
    "scriptSig": {
    "asm": "3045022100e277877245bbbe9dd3a67373c55246b20af0b2cb18462021e1a3322064f42eb902204cf87624132cb1d9e72d0fb5611142d1f6a1c7d35cd53aa6e38e6723d57a6dd601 0436ca43ad71534f13cfdc8b2da6358eaf70e93de833710a986b7ff67c403e45845fddeed1a470c840ed78833d3a61c313a7f21f1fa4dfca3d3d370eb1f1d209d0",
    "hex": "483045022100e277877245bbbe9dd3a67373c55246b20af0b2cb18462021e1a3322064f42eb902204cf87624132cb1d9e72d0fb5611142d1f6a1c7d35cd53aa6e38e6723d57a6dd601410436ca43ad71534f13cfdc8b2da6358eaf70e93de833710a986b7ff67c403e45845fddeed1a470c840ed78833d3a61c313a7f21f1fa4dfca3d3d370eb1f1d209d0"
    },
    "sequence": 4294967295,
    "n": 0,
    "addr": "16VvieA7tLFZx5aRb5q8bJTZuV378A8pWv",
    "valueSat": 80000,
    "value": 0.0008,
    "doubleSpentTxID": null
    }
    ],
    "vout": [
    {
    "value": "0.00070000",
    "n": 0,
    "scriptPubKey": {
    "asm": "OP_DUP OP_HASH160 d1d63de21e37c2845b9c134edd02a74881a53d1e OP_EQUALVERIFY OP_CHECKSIG",
    "hex": "76a914d1d63de21e37c2845b9c134edd02a74881a53d1e88ac",
    "reqSigs": 1,
    "type": "pubkeyhash",
    "addresses": [
    "1L8WssQRCrDKRSF5MwUb2E4HhGzkVTP93U"
    ]
    },
    "spentTxId": "989845a77e49d96aff4538f194742706d49fb82f63d86b1da9c18fb0394d8319",
    "spentIndex": 69,
    "spentTs": 1452670229
    }
    ],
    "blockhash": "00000000000000000541a3e55901b3dc92619067165320a454f59d8e9cf151cc",
    "confirmations": 1168,
    "time": 1452588715,
    "blocktime": 1452588715,
    "valueOut": 0.0007,
    "size": 224,
    "valueIn": 0.0008,
    "fees": 0.0001
*/
    
    
    var txid = ""
    var version: Int = 0
    var locktime: Int = 0
    var blockhash = ""
    var confirmations: Int = 0
    var blockHeight: Int = 0
    var timestamp: Int = 0
    var blocktime: Int = 0
    var valueOut: NSDecimalNumber = 0
    var size: Int = 0
    var valueIn: NSDecimalNumber = 0
    var fees: NSDecimalNumber = 0
    var vinTxs = [TransactionUnit]()
    var voutTxs = [TransactionUnit]()
}
