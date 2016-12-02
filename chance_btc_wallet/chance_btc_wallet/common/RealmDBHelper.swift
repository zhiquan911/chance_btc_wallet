//
//  RealmDBHelper.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/11/23.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit
import RealmSwift

class RealmDBHelper {
    
    static let kRealmDBVersion: UInt64 = 0
    
    //数据库路径
    static var databaseFilePath: URL {
        let fileManager = FileManager.default
        var directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directoryURL = directoryURL.appendingPathComponent("wallet_data")
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try! fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
    
    /// 全局唯一实例, 获取钱包数据库
    static var txDB: Realm = {
        // 通过配置打开 Realm 数据库
        var path = RealmDBHelper.databaseFilePath.appendingPathComponent("tx")
        
        //创建子目录
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            try! fileManager.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        path.appendPathComponent("wallet_tx")
        path.appendPathExtension("realm")
        let config = Realm.Configuration(fileURL: path,
                                         schemaVersion: RealmDBHelper.kRealmDBVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if (oldSchemaVersion < RealmDBHelper.kRealmDBVersion) {
                                                
                                            }
        })
        let realm = try! Realm(configuration: config)
        return realm
    }()
    

    /// 账户体系数据库
    static var acountDB: Realm {
        return try! Realm()
    }
    
    
    /// 检查种子对应的用户体系数据库存不存在
    ///
    /// - Parameter seedHash:
    /// - Returns: 
    class func checkRealmForWalletExist(seedHash: String) -> Bool {
        var path = RealmDBHelper.databaseFilePath.appendingPathComponent("accounts")
        
        path.appendPathComponent("wallet_\(seedHash)")
        path.appendPathExtension("realm")
        
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path.path)
    }
    
    /// 使用钱包的种子哈希切换默认的数据
    ///
    /// - Parameter seedHash: 种子哈希
    class func setDefaultRealmForWallet(seedHash: String) {
        // 通过配置打开 Realm 数据库
        var path = RealmDBHelper.databaseFilePath.appendingPathComponent("accounts")
        
        //创建子目录
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            try! fileManager.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        path.appendPathComponent("wallet_\(seedHash)")
        path.appendPathExtension("realm")
        let config = Realm.Configuration(fileURL: path,
                                         schemaVersion: RealmDBHelper.kRealmDBVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if (oldSchemaVersion < RealmDBHelper.kRealmDBVersion) {
                                                
                                            }
        })
        Log.debug("db path = \(path.absoluteString)")
        Realm.Configuration.defaultConfiguration = config
    }

}

// MARK: - 扩展Results
extension Results {
    
    /**
     转为普通数组
     
     - returns:
     */
    func toArray() -> [T] {
        var arr = [T]()
        for obj in self {
            arr.append(obj)
        }
        return arr
    }
    
}
