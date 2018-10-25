//
//  ViewController.swift
//  MyLocation
//
//  Created by 关东升 on 2014-10-18.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //经度
    @IBOutlet weak var txtLng: UITextField!
    //纬度
    @IBOutlet weak var txtLat: UITextField!
    //高度
    @IBOutlet weak var txtAlt: UITextField!
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //定位服务管理对象初始化
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 1000.0
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //开始定位
        self.locationManager.startUpdatingLocation()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //停止定位
       self.locationManager.stopUpdatingLocation()
    }

    //MARK: --Core Location委托方法用于实现位置的更新
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var currLocation = locations[locations.count - 1] as! CLLocation
        
        self.txtLat.text = String(format:"%3.5f", currLocation.coordinate.latitude)
        self.txtLng.text = String(format:"%3.5f", currLocation.coordinate.longitude)
        self.txtAlt.text = String(format:"%3.5f", currLocation.altitude)
        NSLog("%3.5f",  currLocation.coordinate.latitude)

    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("error: %@",error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        
        if status == CLAuthorizationStatus.AuthorizedAlways {
            NSLog("AuthorizedAlways")
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            NSLog("AuthorizedWhenInUse")
        } else if status == CLAuthorizationStatus.Denied {
            NSLog("Denied")
        } else if status == CLAuthorizationStatus.Restricted {
            NSLog("Restricted")
        } else if status == CLAuthorizationStatus.NotDetermined {
            NSLog("NotDetermined")
        }
        
    }
    
}

