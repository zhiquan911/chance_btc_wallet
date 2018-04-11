//
//  ICloudUtils.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/13.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit


/// iCloud辅助工具
class CloudUtils: NSObject {
    
    var myMetadataQuery: NSMetadataQuery = NSMetadataQuery()
    
    //全局唯一实例
    static var shared: CloudUtils = {
        let instance = CloudUtils()
        return instance
    }()
    
    override init() {
        super.init()
        self.addNotification()
    }
    
    
    /// 设备是否支持icloud
    var iCloud: Bool {
        //设置是否登录icloud账号
        if FileManager().ubiquityIdentityToken == nil {
            return false
        } else {
            return true
        }
    }
    
    
    /// 添加通知
    func addNotification() {
        
        //数据获取完成
        NotificationCenter.default.addObserver(self, selector: #selector(self.metadataQueryDidFinishGathering), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: self.myMetadataQuery)
        
        
        
    }
    
    
    /// 搜索文档
    func query() {
        //设置搜索文档
        self.myMetadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        self.myMetadataQuery.start()
    }
    
}


// MARK: - 监听方法实现
extension CloudUtils {
    
    //
    /// 获取icloud文档列表
    ///
    /// - Parameter noti:
    @objc func metadataQueryDidFinishGathering(noti: Notification){
        Log.debug("MetadataQueryDidFinishGathering")
        let items = self.myMetadataQuery.results        //查询结果集
        for obj in items {
            let item = obj as! NSMetadataItem
            //获取文件名
            let fileName = item.value(forAttribute: NSMetadataItemFSNameKey) as! String
            Log.debug("fileName = \(fileName)")
        }
    }
}
