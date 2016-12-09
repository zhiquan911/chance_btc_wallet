//
//  MultiSigUtilsTests.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/9.
//  Copyright © 2016年 chance. All rights reserved.
//

import XCTest
@testable import Pods_chance_btc_wallet


/// 多重签名交易表单单元测试
class MultiSigTransactionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    /// 解析多重签名交易单为json字符串
    func testEncodeToJSON() {
        let rawTx = "01000000021138c1e2f7735a8589fa2a3df2426fbaf24a047330c5a0dc14ffadf7dd8767b10000000000ffffffff6d3c772c389561f20b4afec072cbb61cbe15b42aa37fb50e98ad78f3021241790000000000ffffffff02409c0000000000001976a914d1f9af334c34de5558c0d6785d2f22e25a9eff6d88ac80131c000000000017a914dde71db06038ed3a3bead881b20176dd6de8ec068700000000"
        let keySignatures: [String: [String]] = [
            "0":[
                "00304402205f11cf0824a435f6445b20f941d74d4f1e879bd5b3b6c2cb72e58e5e335796b9022042cb6d3b28c70316e71b6ae6b4ca4103cb25bc3f57dab7f5fe9a5534f2d5e30f01",
                "00304402205f11cf0824a435f6445b20f941d74d4f1e879bd5b3b6c2cb72e58e5e335796b9022042cb6d3b28c70316e71b6ae6b4ca4103cb25bc3f57dab7f5fe9a5534f2d5e30f01",
            ],
            "1":[
                "023044022059bdd1ff6a07bc3bcd4fc58f8a171ee2a77d7ac22c9f69a812d665032da48259022076fe2dcd69b2e0bf05e87c09a419e3f1202529f8a39858ae0170a84be34276e201",
                "023044022059bdd1ff6a07bc3bcd4fc58f8a171ee2a77d7ac22c9f69a812d665032da48259022076fe2dcd69b2e0bf05e87c09a419e3f1202529f8a39858ae0170a84be34276e201",
            ]
        ]
        
        let redeemScriptHex = "532103324c40d0042fb1c21be5d0688e1e0c7090e16d0fc6abbb0563ba368bc2d7f20b2102c6287fd02ec3f5c3689d9152688553670d9f84fdc124c621e2ffe7be8ccc60bc21028c42e572d465753610915266f5f7855ebcb74b7f7db434a2732685cb290c20a953ae"
        
        //初始表单
        let mtx = MultiSigTransaction(rawTx: rawTx,
                                      keySignatures: keySignatures,
                                      redeemScriptHex: redeemScriptHex)
        let text = mtx.json
        print(text)
    }
    
    /// 使用json字符串输出话多重签名表单
    func testdecodeFromJSON() {
        let rawTx = "multisig://{\"rawTx\":\"01000000021138c1e2f7735a8589fa2a3df2426fbaf24a047330c5a0dc14ffadf7dd8767b10000000000ffffffff6d3c772c389561f20b4afec072cbb61cbe15b42aa37fb50e98ad78f3021241790000000000ffffffff02409c0000000000001976a914d1f9af334c34de5558c0d6785d2f22e25a9eff6d88ac80131c000000000017a914dde71db06038ed3a3bead881b20176dd6de8ec068700000000\",\"redeemScriptHex\":\"532103324c40d0042fb1c21be5d0688e1e0c7090e16d0fc6abbb0563ba368bc2d7f20b2102c6287fd02ec3f5c3689d9152688553670d9f84fdc124c621e2ffe7be8ccc60bc21028c42e572d465753610915266f5f7855ebcb74b7f7db434a2732685cb290c20a953ae\",\"keySignatures\":{\"0\":[\"00304402205f11cf0824a435f6445b20f941d74d4f1e879bd5b3b6c2cb72e58e5e335796b9022042cb6d3b28c70316e71b6ae6b4ca4103cb25bc3f57dab7f5fe9a5534f2d5e30f01\",\"00304402205f11cf0824a435f6445b20f941d74d4f1e879bd5b3b6c2cb72e58e5e335796b9022042cb6d3b28c70316e71b6ae6b4ca4103cb25bc3f57dab7f5fe9a5534f2d5e30f01\"],\"1\":[\"023044022059bdd1ff6a07bc3bcd4fc58f8a171ee2a77d7ac22c9f69a812d665032da48259022076fe2dcd69b2e0bf05e87c09a419e3f1202529f8a39858ae0170a84be34276e201\",\"023044022059bdd1ff6a07bc3bcd4fc58f8a171ee2a77d7ac22c9f69a812d665032da48259022076fe2dcd69b2e0bf05e87c09a419e3f1202529f8a39858ae0170a84be34276e201\"]}}"
       
//        let rawTx = ""
        
        //初始表单
        do {
            let mtx = try MultiSigTransaction(json: rawTx)
            print(mtx)
        } catch {
            print(error)
        }
    }
}
