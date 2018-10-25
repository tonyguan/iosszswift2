//
//  AddHomeViewController.swift
//  HomeKitDemo
//
//  Created by 关东升 on 15/7/29.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit
import HomeKit

class AddHomeViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var homeManager: HMHomeManager!
    var home: HMHome!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func save(sender: AnyObject) {
         homeManager.addHomeWithName(textField.text, completionHandler: { (home, error) -> Void in
            if error != nil {
                NSLog("error : %@", error)
            } else  {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
         })
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
