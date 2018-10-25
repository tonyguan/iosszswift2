//
//  ViewController.swift
//  KVStore
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

//背景音乐 存储键
let UbiquitousMusicKey = "MusicKey"
//音效 存储键
let UbiquitousSoundKey = "SoundKey"

class ViewController: UITableViewController {
    
    @IBOutlet weak var switchMusic: UISwitch!    
    @IBOutlet weak var switchSound: UISwitch!
    
    var store = NSUbiquitousKeyValueStore.defaultStore()
    var storeDidChangeObserver : AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化控件状态
        self.switchMusic.setOn(self.store.boolForKey(UbiquitousMusicKey), animated: true)
        self.switchSound.setOn(self.store.boolForKey(UbiquitousSoundKey), animated: true)

        self.storeDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil, queue: nil) { (note) -> Void in
            //更新控件状态
            self.switchMusic.setOn(self.store.boolForKey(UbiquitousMusicKey), animated: true)
            self.switchSound.setOn(self.store.boolForKey(UbiquitousSoundKey), animated: true)
            
            let alert = UIAlertView(title: "iCloud变更通知", message: "你的iCloud存储数据已经变更", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
        self.store.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self.storeDidChangeObserver)
    }


    @IBAction func setData(sender: AnyObject) {
        //存储iCloud
        self.store.setBool(self.switchMusic.on, forKey: UbiquitousMusicKey)
        self.store.setBool(self.switchSound.on, forKey: UbiquitousSoundKey)
        self.store.synchronize()
    }
}

