//
//  ViewController.swift
//  BeaconDevice
//
//  Created by 关东升 on 15/2/9.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit
import CoreBluetooth
import CoreLocation

let kUUID = "88936DF5-E10B-4382-89D6-8AE0D80373F8"
let kID = "com.51work6.AirLocate"
let kPower = -59

class ViewController: UIViewController , CBPeripheralManagerDelegate {

    var peripheralManager : CBPeripheralManager!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    @IBAction func valueChanged(sender: AnyObject) {
        
        let swc = sender as! UISwitch
        if swc.on {
            let uuid = NSUUID(UUIDString: kUUID)
            let region = CLBeaconRegion(proximityUUID: uuid, identifier: kID)
            let peripheralData = region.peripheralDataWithMeasuredPower(kPower) 
            if(peripheralData != nil) {
                var dict:NSDictionary = peripheralData
                self.peripheralManager.startAdvertising(dict as [NSObject : AnyObject])
            }
        } else {
            self.peripheralManager.stopAdvertising()
        }
    }
    
    //MARK: --实现CBPeripheralManagerDelegate协议
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        NSLog("外设状态变化")
    }
}

