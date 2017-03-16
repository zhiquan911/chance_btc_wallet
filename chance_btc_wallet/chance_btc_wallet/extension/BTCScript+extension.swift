//
//  BTCScript+extension.swift
//  Chance_wallet
//
//  Created by Chance on 16/2/1.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation

extension BTCScript {
    
    /**
     如果脚本是多重签名的赎回脚本获取公钥数组和地址数组
     
     - returns: 公钥和
     */
    func getMultisigPublicKeys() -> ([Data], [String])? {
        if self.isMultisignatureScript {
            // multisig script must have at least 4 ops ("OP_1 <pubkey> OP_1 OP_CHECKMULTISIG")
            if self.scriptChunks.count < 4 {
                return nil
            }
            var list = [Data]()
            var addresses = [String]()
            self.enumerateOperations({
                (i, opcode, pushdata, stop) -> Void in
                if opcode == BTCOpcode.OP_INVALIDOPCODE {
                    let publicKey = BTCKey(publicKey: pushdata)
                    addresses.append((publicKey?.compressedPublicKeyAddress.string)!)
                    list.append(pushdata!)
                }
            })
            
            return (list, addresses)
        } else {
            return nil
        }
    }
    
    
    /// 获取必要的签名数目
    var requiredSignatures: Int {
        if !self.isMultisignatureScript {
            return 0
        }
        
        let chunks = self.scriptChunks as! [BTCScriptChunk]
        //必要的签名数目
        let chunk = chunks[self.scriptChunks.count - 2]
        if !chunk.isOpcode {
            return 0
        }
        let n = BTCSmallIntegerFromOpcode(chunk.opcode);
        return n
    }
}


extension String {
    
    
    /// 字符串转化为比特币脚本
    ///
    /// - Returns: 
    func toBTCScript() -> BTCScript? {
        let script = BTCScript(hex: self)
        return script
    }
}
