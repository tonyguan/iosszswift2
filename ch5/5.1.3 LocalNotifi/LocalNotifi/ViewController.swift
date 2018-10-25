//
//  ViewController.swift
//  LocalNotifi
//
//  Created by 关东升 on 2016-2-18.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func scheduleStart(sender: AnyObject) {
        let localNotification = UILocalNotification()
        //设置通知10秒后触发.
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
        //设置通知消息
        localNotification.alertBody = "计划通知，新年好!"
        //设置通知标记数
        localNotification.applicationIconBadgeNumber = 2
        
        //设置通知出现时候声音
        localNotification.soundName = UILocalNotificationDefaultSoundName
        //设置动作按钮的标题
        localNotification.alertAction = "View Details"
        
        //计划通知
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    
    @IBAction func scheduleEnd(sender: AnyObject) {
        //结束计划通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    @IBAction func nowStart(sender: AnyObject) {
        let localNotification = UILocalNotification()
        //设置通知消息
        localNotification.alertBody = "立刻通知，新年好!"
        //设置通知标记数
        localNotification.applicationIconBadgeNumber = 2
        
        //设置通知出现时候声音
        localNotification.soundName = UILocalNotificationDefaultSoundName
        //设置动作按钮的标题
        localNotification.alertAction = "View Details"
        
        //立刻发出通知
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)

    }

}

