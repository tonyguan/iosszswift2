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

class Client: NSObject, NSNetServiceBrowserDelegate {
   
    var services : Set<NSNetService>
    var serviceBrowser : NSNetServiceBrowser
    
    var port : Int = 0
    
    override init() {
       
        self.serviceBrowser = NSNetServiceBrowser()
        self.services = Set<NSNetService>()
        super.init()
        
        self.serviceBrowser.delegate = self
        //设置解析地址超时时
        self.serviceBrowser.searchForServicesOfType("_tonyipp._tcp.", inDomain: "local.")
        
    }
    
    //MARK: --NSNetServiceBrowserDelegate实现委托协议    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        
        NSLog("didFindService: %@  count:%d", aNetService.name, self.services.count)
        self.services.insert(aNetService)
        
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        NSLog("didRemoveService")
        self.services.remove(aNetService)
    }
    
}
