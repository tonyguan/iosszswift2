//
//  ViewController.swift
//  HandoffDemo
//
//  Created by 关东升 on 15/8/1.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

let controllerActivityType = "com.51work6.HandoffDemo.Controller"
let powerSwitchKey = "powerSwitch_key"
let brightnessSilderKey = "brightnessSilder_key"

class ViewController: UIViewController, NSUserActivityDelegate {

    var activity : NSUserActivity?
    
    @IBOutlet weak var powerSwitch: UISwitch!
    
    @IBOutlet weak var brightnessSilder: UISlider!
    
    @IBOutlet weak var brightnessValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //实例化activity对象
        self.activity = NSUserActivity(activityType: controllerActivityType)
        self.activity!.userInfo = getActivityInfoData()
        self.activity!.title = "灯泡控制器"
        self.activity!.delegate = self
        
        self.activity!.becomeCurrent()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.activity!.invalidate()
        self.activity!.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //准备activity中的数据
    func getActivityInfoData() -> [String : AnyObject] {
        
        var activityInfo = [String : AnyObject]()
        activityInfo[powerSwitchKey] = powerSwitch.on
        activityInfo[brightnessSilderKey] = brightnessSilder.value
        
        return activityInfo
    }

    @IBAction func switchValueChanged(sender: AnyObject) {        
        self.activity!.needsSave = true
    }
    
    @IBAction func silderValueChanged(sender: AnyObject) {
        let newValue = self.brightnessSilder.value
        self.brightnessValue.text = String(format: "%0.0f", newValue)
        self.activity!.needsSave = true
    }
    
    //MARK: --实现NSUserActivityDelegate协议方法
    func userActivityWillSave(userActivity: NSUserActivity) {
        userActivity.userInfo = getActivityInfoData()
    }
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        if activity.activityType == controllerActivityType {
            
            let info = activity.userInfo as! [String : AnyObject]
            let switchValue = info[powerSwitchKey] as! Bool
            let silderValue = info[brightnessSilderKey] as! Float
            
            self.powerSwitch.setOn(switchValue, animated: true)
            self.brightnessSilder.value = silderValue
            self.brightnessValue.text = String(format: "%0.0f", silderValue)
        }
    }
}

