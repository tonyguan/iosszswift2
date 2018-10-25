//
//  MyCloudDocument.swift
//  DoucmentDemo
//
//  Created by 关东升 on 15/7/16.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

class MyCloudDocument: UIDocument {
    var contents : NSString!
    
    //加载数据
    override func loadFromContents(contents: AnyObject, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        
        let qContents = contents as! NSData
        
        if qContents.length > 0 {
            self.contents = NSString(data: qContents, encoding: NSUTF8StringEncoding)
        }
        
        return true
    }
    
    //保存数据
    override func contentsForType(typeName: String, error outError: NSErrorPointer) -> AnyObject? {
        let resContents = self.contents.dataUsingEncoding(NSUTF8StringEncoding)
        return resContents
    }
}
