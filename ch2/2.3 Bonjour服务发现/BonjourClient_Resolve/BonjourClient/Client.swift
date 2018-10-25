//
//  Client.swift
//  BonjourClient
//
//  Created by 关东升 on 15/6/5.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

class Client: NSObject, NSNetServiceDelegate {
   
    var services : Set<NSNetService>
    var service : NSNetService
    
    var port : Int = 0
    
    override init() {
       
        self.service = NSNetService(domain: "local.", type: "_tonyipp._tcp.", name: "tony")
        self.services = Set<NSNetService>()
        super.init()
        
        self.service.delegate = self
        //设置解析地址超时时
        self.service.resolveWithTimeout(1.0)
        
    }
    
    //MARK: --NSNetServiceDelegate实现委托协议   
    
    func netServiceWillResolve(sender: NSNetService) {
        NSLog("netServiceWillResolve")
    }
    
    func netServiceDidResolveAddress(netService: NSNetService) {
        NSLog("netServiceDidResolveAddress")
        self.services.insert(netService)
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        NSLog("didNotResolve: %@",errorDict)
    }
}
