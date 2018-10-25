//
//  ViewController.swift
//  WhereAmI
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
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var txtQueryKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func geocodeQuery(sender: AnyObject) {
        
        if (self.txtQueryKey.text == nil) {
            return
        }
        
        var geocoder = CLGeocoder()

        geocoder.geocodeAddressString(self.txtQueryKey.text, completionHandler: { (placemarks, error) -> Void in
            
            if placemarks != nil &&  placemarks.count  > 0 {
                
                NSLog("查询记录数：%i", placemarks.count)
                
                let placemark = placemarks[0] as! CLPlacemark
                
                let coord = placemark.location.coordinate
                let address = placemark.addressDictionary
                
                var place = MKPlacemark(coordinate:coord, addressDictionary:address)

                let mapItem = MKMapItem(placemark: place)
                mapItem.openInMapsWithLaunchOptions(nil)
                
//                //地图上设置行车路线
//                let options = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving,
//                    forKey: MKLaunchOptionsDirectionsModeKey)
//                let mapItem = MKMapItem(placemark: place)
//                mapItem.openInMapsWithLaunchOptions(options)
                
            }
            
            //关闭键盘
            self.txtQueryKey.resignFirstResponder()
        })

    }

   /*
    @IBAction func geocodeQuery(sender: AnyObject) {
        
        if (self.txtQueryKey.text == nil) {
            return
        }
        
        var geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.txtQueryKey.text, completionHandler: { (placemarks, error) -> Void in
            
            if placemarks == nil {
                return
            }
            var array = NSMutableArray()
            
            for item in placemarks {
                
                let placemark = item as CLPlacemark
                
                let coord = placemark.location.coordinate
                let address = placemark.addressDictionary
                
                var place = MKPlacemark(coordinate:coord, addressDictionary:address)
                
                let mapItem = MKMapItem(placemark: place)
                mapItem.openInMapsWithLaunchOptions(nil)
                
                array.addObject(mapItem)
            }
            
            if (array.count > 0) {
                MKMapItem.openMapsWithItems(array, launchOptions: nil)
            }
            
            //关闭键盘
            self.txtQueryKey.resignFirstResponder()
        })
        
    }
*/
    
}

