//
//  ViewController.swift
//  SinaWeiBo
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

import Social

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo) {
            
            composeViewController.completionHandler = { result -> Void in
                
                composeViewController.dismissViewControllerAnimated(true, completion: nil)
                
                switch result {
                case .Cancelled:
                    NSLog("取消...")
                case .Done:
                    NSLog("发送...")
                }
            }
            
            composeViewController.addImage(UIImage(named: "icon@2x.png"))
            composeViewController.setInitialText("请大家登录智捷课堂服务网站。")
            composeViewController.addURL(NSURL(string: "http://www.51work6.com"))
            
            //模态视图呈现，如果是iPad则要Popover视图呈现
            self.presentViewController(composeViewController, animated: true, completion: nil)
            
        }
    }
    
}