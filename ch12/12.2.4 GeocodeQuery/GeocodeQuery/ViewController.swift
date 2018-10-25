//
//  ViewController.swift
//  GeocodeQuery
//
//  Created by 关东升 on 14/12/25.
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
import AddressBook

class ViewController: UIViewController {

    @IBOutlet weak var txtView: UITextView!
    
    @IBOutlet weak var txtQueryKey: UITextField!
    
    @IBAction func geocodeQuery(sender: AnyObject) {
        
        if self.txtQueryKey.text == nil {
            return
        }
        
        var geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.txtQueryKey.text, completionHandler: { (placemarks, error) -> Void in
            
            if placemarks != nil && placemarks.count > 0 {
                NSLog("查询记录数：%i", placemarks.count)
                
                let placemark = placemarks[0] as! CLPlacemark
                let addressDictionary = placemark.addressDictionary as NSDictionary
                
                var str:NSMutableString = ""
                
                if let address = addressDictionary.objectForKey(kABPersonAddressStreetKey) as? String {
                    str.appendString(address)
                    str.appendString(" \n")
                }
                if let state = addressDictionary.objectForKey(kABPersonAddressStateKey) as? String {
                    str.appendString(state)
                    str.appendString(" \n")
                }
                if let city = addressDictionary.objectForKey(kABPersonAddressCityKey) as? String {
                    str.appendString(city)
                    str.appendString(" \n")
                }
                
                let location = placemark.location
                
                let lng = location.coordinate.longitude
                let lat = location.coordinate.latitude
                
                self.txtView.text = String(format: "%3.5f \n%3.5f  \n%@", lng, lat, str)
            }
            //关闭键盘
            self.txtQueryKey.resignFirstResponder()
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

