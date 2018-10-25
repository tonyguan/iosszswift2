//
//  DetailViewController.swift
//  PassDemo
//
//  Created by 关东升 on 15/7/26.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit
import PassKit

class DetailViewController: UIViewController {

    @IBOutlet weak var lblSerialNumber: UILabel!
    
    @IBOutlet weak var lblOrganizationName: UILabel!
    
    @IBOutlet weak var lblRelevantDate: UILabel!
    
    @IBOutlet weak var lblLocalizedDescription: UILabel!
    
    var pass : PKPass!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblOrganizationName.text = self.pass.organizationName
        self.lblLocalizedDescription.text = self.pass.localizedDescription
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        if self.pass.relevantDate != nil {
            self.lblRelevantDate.text = df.stringFromDate(self.pass.relevantDate)
        }
        self.lblSerialNumber.text = self.pass.serialNumber
    }
    
    @IBAction func remove(sender: AnyObject) {
        NSLog("删除Pass")
        let passLib = PKPassLibrary()
        passLib.removePass(self.pass)
        //返回上一级视图
        self.navigationController?.popViewControllerAnimated(true)
    }
}
