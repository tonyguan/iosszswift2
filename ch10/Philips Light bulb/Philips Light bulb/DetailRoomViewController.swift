//
//  DetailRoomViewController.swift
//  HomeKitDemo
//
//  Created by 关东升 on 15/7/30.
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

let accessoryName = "Light"

class DetailRoomViewController: UIViewController, HMAccessoryBrowserDelegate {
    
    var home: HMHome!
    var room: HMRoom!
    var lightAccessory: HMAccessory!
    var accessoryBrowser = HMAccessoryBrowser()
    
    var brightnessCharacteristic: HMCharacteristic!
    var powerStateCharacteristic: HMCharacteristic!
    
    @IBOutlet weak var powerSwitch: UISwitch!
    
    @IBOutlet weak var brightnessSilder: UISlider!
    
    @IBOutlet weak var brightnessValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessoryBrowser.delegate = self
        self.findAccessory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.accessoryBrowser.stopSearchingForNewAccessories()
    }
    
    func findAccessory(){
        
        if let accessories = room.accessories {
            for accessory in accessories as! [HMAccessory]{
                if accessory.name == accessoryName {
                    self.lightAccessory = accessory
                }
            }
        }
        
        // 开始查找配件
        if self.lightAccessory == nil {
            self.accessoryBrowser.startSearchingForNewAccessories()
        } else {
            self.findServicesForAccessory(self.lightAccessory)
        }
        
    }
    //MARK: --实现HMAccessoryBrowserDelegate协议
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory!) {
        NSLog("发现配件...")
        
        if accessory.name == accessoryName {
            self.home.addAccessory(accessory, completionHandler: { [weak self] (error) -> Void in
                
                if error != nil {
                    NSLog("安装配件失败。")
                } else {
                    self!.home.assignAccessory(accessory, toRoom: self!.room, completionHandler: { (error) -> Void in
                        self!.findServicesForAccessory(accessory)
                    })
                }
                
            })
        }
    }
    
    
    func findServicesForAccessory(accessory: HMAccessory){
        NSLog("查找配件的服务...")
        for service in accessory.services as! [HMService]{
            NSLog(" 服务名 = \(service.name)")
            NSLog(" 服务类型 = \(service.serviceType)")
            
            NSLog(" 查找服务中的特征...")
            findCharacteristicsOfService(service)
        }
    }
    
    func findCharacteristicsOfService(service: HMService){
        for characteristic in service.characteristics as! [HMCharacteristic]{
            NSLog("   特征类型 = \(characteristic.characteristicType)")
            
            if characteristic.characteristicType == HMCharacteristicTypeBrightness{
                brightnessCharacteristic = characteristic
                brightnessCharacteristic.readValueWithCompletionHandler({ [weak self] (error) -> Void in
                    if error != nil {
                        NSLog("error : %@", error)
                    } else  {
                        let oldValue = self!.brightnessCharacteristic.value as! Float
                        NSLog("oldValue : \(oldValue)")
                        self!.brightnessSilder.value = oldValue
                        self!.brightnessValue.text = String(format: "%0.0f", oldValue)
                    }
                    })
                
            } else if characteristic.characteristicType == HMCharacteristicTypePowerState {
                powerStateCharacteristic = characteristic
                powerStateCharacteristic.readValueWithCompletionHandler({ [weak self] (error) -> Void in
                    if error != nil {
                        NSLog("error : %@", error)
                    } else  {
                        let oldValue = self!.powerStateCharacteristic.value as! Bool
                        NSLog("oldValue : \(oldValue)")
                        self!.powerSwitch.setOn(oldValue, animated: true)
                    }
                    })
            }
        }
    }
    
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        let newValue = self.powerSwitch.on
        self.powerStateCharacteristic.writeValue(newValue, completionHandler: {(error) -> Void in
            if error != nil {
                NSLog("Power状态写入失败: %@", error)
            }
        })
    }
    
    @IBAction func silderValueChanged(sender: AnyObject) {
        let newValue = self.brightnessSilder.value
        self.brightnessCharacteristic.writeValue(newValue, completionHandler: {(error) -> Void in
            if error != nil {
                NSLog("亮度写入失败: %@", error)
            }
        })
        self.brightnessValue.text = String(format: "%0.0f", newValue)
    }
    
}
