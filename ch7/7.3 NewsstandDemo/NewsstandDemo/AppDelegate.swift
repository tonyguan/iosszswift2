//
//  AppDelegate.swift
//  NewsstandDemo
//
//  Created by 关东升 on 15/7/21.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Newsstand下载每天一次，为了在开发阶段测试需要设置这个参数
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NKDontThrottleNewsstandContentNotifications")
        
        //注册接收通知类型
        let settings = UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Badge
                | UIUserNotificationType.Sound
                | UIUserNotificationType.Alert, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        //处理应用程序终止时候未下载完成的处理
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeDownload:", name: ResumeDownloadNotification, object: nil)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        NSLog("设备令牌: %@", deviceToken)
        var tokenString = deviceToken.description
        var charsets = NSCharacterSet(charactersInString: "<>")
        tokenString = tokenString.stringByTrimmingCharactersInSet(charsets)
        tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
        NSLog("处理后的设备令牌: %@", tokenString)
        
        //设备令牌发送给服务器
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("error : %@",error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        NSLog("application:didReceiveRemoteNotification: - %@", userInfo)
        
        let aps = userInfo["aps"] as? [String : AnyObject]
        
        if let available = aps!["content-available"] as? Int {
            if available == 1 {
                if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                    NSLog("应用状态：Active")
                    
                    let alert = UIAlertView(title: "新的杂志",
                        message: "有新的杂志已经发布",
                        delegate: nil,
                        cancelButtonTitle: "Close")
                    
                    alert.show()
                    
                } else {
                    NSLog("应用状态：Background 或 inActive ")
                    NSNotificationCenter.defaultCenter().postNotificationName(DownloadNotification, object: self)
                }
            }
            
        }
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

