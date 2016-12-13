//
//  CHDocument.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/10.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

class CHDocument: UIDocument {
    
    var fileContent: Data!
    
    override func contents(forType typeName: String) throws -> Any {
        return self.fileContent
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if self.fileContent == nil {
            self.fileContent = Data()
        }
        self.fileContent = contents as! Data
    }
    
    

}


// MARK: - 实现iCloud自动同步的相关支持
extension CHDocument {
 
    
    /// 获取icloud文档路径
    ///
    /// - Returns:
    class func getiCloudDocumentURL() -> URL? {
        //设备没有开启icloud权限会返回nil
        if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            //目前icloud不支持建立子文件夹，很多教程都只是存在Documents，所以只能默认存放在这里
            //以后再扩展迁移数据
            return url.appendingPathComponent("Documents")
            
        }
        
        return nil
    }
    
}
