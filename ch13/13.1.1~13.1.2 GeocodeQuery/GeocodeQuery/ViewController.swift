//
//  ViewController.swift
//  GeocodeQuery
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

class ViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var txtQueryKey: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.mapType = MKMapType.Standard
        self.mapView.delegate = self
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
                
                //调整地图位置和缩放比例
                let viewRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 10000, 10000)
                self.mapView.setRegion(viewRegion, animated: true)
                
                let annotation = MyAnnotation(coordinate: placemark.location.coordinate)
                
                annotation.city = placemark.locality
                annotation.state = placemark.administrativeArea
                annotation.streetAddress = placemark.thoroughfare
                annotation.zip = placemark.postalCode
                
                self.mapView.addAnnotation(annotation)
                
            }
            
            //关闭键盘
            self.txtQueryKey.resignFirstResponder()
        })
        
        
    }
    
    //MARK: --Map View Delegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("PIN_ANNOTATION") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PIN_ANNOTATION")
        }
        annotationView!.pinColor = MKPinAnnotationColor.Purple
        annotationView!.animatesDrop = true
        annotationView!.canShowCallout = true
        
        return annotationView!
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        NSLog("error : %@", error.description)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.centerCoordinate = userLocation.location.coordinate;
    }
    
}

