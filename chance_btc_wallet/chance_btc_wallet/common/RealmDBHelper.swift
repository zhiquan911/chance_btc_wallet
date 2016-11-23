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
        directoryURL = directoryURL.appendingPathComponent("api_cache_data")
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try! fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
    
    /// 全局唯一实例
    static var sharedInstance: Realm!
    
    
    //获取某个用户独立的数据库
    class func setDefaultAccountDB(address: String) -> Realm {
        // 通过配置打开 Realm 数据库
        var path = RealmDBHelper.databaseFilePath.appendingPathComponent("database_\(address)")
        path = path.appendingPathExtension("realm")
        let config = Realm.Configuration(fileURL: path,
                                         schemaVersion: RealmDBHelper.kRealmDBVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if (oldSchemaVersion < RealmDBHelper.kRealmDBVersion) {
                                                
                                            }
        })
        let realm = try! Realm(configuration: config)
        RealmDBHelper.sharedInstance = realm
        return realm
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
