
//
//  ViewController.swift
//  APPClient
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

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var lblRanging: UILabel!
    
    var locationManager : CLLocationManager!
    var region : CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        let uuid = NSUUID(UUIDString: kUUID)
        self.region = CLBeaconRegion(proximityUUID: uuid, identifier: kID)
        
        self.locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
        self.locationManager.stopMonitoringForRegion(self.region)
        self.locationManager.stopRangingBeaconsInRegion(self.region)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func rangValue(sender: AnyObject) {
        let swc = sender as! UISwitch
        if swc.on {
            self.locationManager.startRangingBeaconsInRegion(self.region)
        } else {
            self.locationManager.stopRangingBeaconsInRegion(self.region)
        }
    }
    
    @IBAction func onClickMonitoring(sender: AnyObject) {
        self.locationManager.startMonitoringForRegion(self.region)
    }
    
    //MARK: --实现CLLocationManagerDelegate委托协议
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        let notification = UILocalNotification()
        if state == .Inside {
            notification.alertBody = "你在围栏内"
        } else if state == .Outside {
            notification.alertBody = "你在围栏外"
        } else {
            return
        }
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
     }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        let notification = UILocalNotification()
        notification.alertBody = "你进入围栏"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        let notification = UILocalNotification()
        notification.alertBody = "你退出围栏"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
       
        let aryBeacons = beacons as NSArray
        
        var predicate = NSPredicate(format: "proximity = %d", CLProximity.Unknown.rawValue)
        let unknownBeacons = aryBeacons.filteredArrayUsingPredicate(predicate)
        if unknownBeacons.count > 0 {
            self.lblRanging.text = "未检测到"
        }
        
        predicate = NSPredicate(format: "proximity = %d", CLProximity.Immediate.rawValue)
        let immediateBeacons = aryBeacons.filteredArrayUsingPredicate(predicate)
        if immediateBeacons.count > 0 {
            self.lblRanging.text = "最接近"
        }
        
        predicate = NSPredicate(format: "proximity = %d", CLProximity.Near.rawValue)
        let nearBeacons = aryBeacons.filteredArrayUsingPredicate(predicate)
        if nearBeacons.count > 0 {
            self.lblRanging.text = "近距离"
        }
        
        predicate = NSPredicate(format: "proximity = %d", CLProximity.Far.rawValue)
        let farBeacons = aryBeacons.filteredArrayUsingPredicate(predicate)
        if farBeacons.count > 0 {
            self.lblRanging.text = "远距离"
        }
        
    }
}

