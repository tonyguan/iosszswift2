//
//  ViewController.swift
//  PassDemo
//
//  Created by 关东升 on 2016-2-18.
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

let SerialNumber = "gT6zrHkaW"

let PASSBOOK_PATH = "/passbook/download.php"
let HOST = "51work6.com"
let USER_ID = "test89111@51work6.com"

class ViewController: UITableViewController,PKAddPassesViewControllerDelegate {

    var passes : [AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //判断Pass库是否可用
        if !PKPassLibrary.isPassLibraryAvailable() {
            NSLog("Pass库不可用。")
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLibraryChange:", name: PKPassLibraryDidChangeNotification, object: nil)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //刷新界面
        self.handleLibraryChange(nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleLibraryChange(notification : NSNotification?) {
        let passLib = PKPassLibrary()
        //排序
        let byName = NSSortDescriptor(key: "localizedName", ascending: true)
        let results: NSArray = passLib.passes() as NSArray
        let sortedResults =  results.sortedArrayUsingDescriptors([byName])
        
        self.passes = sortedResults
        
        self.tableView.reloadData()
    }

    //MARK: --实现表视图数据源协议方法
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = self.passes?.count {
            return count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let pass = self.passes[indexPath.row] as! PKPass
        
        cell.textLabel?.text = pass.localizedName
        cell.detailTextLabel?.text = pass.localizedDescription
        cell.imageView?.image = pass.icon
        
        return cell
    }
    
    //MARK: --PKAddPassesViewControllerDelegate 实现方法
    func addPassesViewControllerDidFinish(controller: PKAddPassesViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSLog("添加Pass")
        //刷新界面
        self.handleLibraryChange(nil)
    }
    
    //MARK: --处理画面跳转
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let pass = self.passes[indexPath!.row] as! PKPass
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.pass = pass
        }
    }
    
    
    @IBAction func add(sender: AnyObject) {
        
        var path = PASSBOOK_PATH
        path = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var param = ["email": USER_ID]
        param["serialNumber"] = SerialNumber
        
        var engine = MKNetworkEngine(hostName: HOST, customHeaderFields: nil)
        var op = engine.operationWithPath(path, params: param, httpMethod:"POST")
        
        op.addCompletionHandler({ (operation) -> Void in
            
            let data  = operation.responseData()
            if data.length > 0 {
                NSLog("下载成功。")
                var error : NSError?
                let newPass = PKPass(data: data, error: &error)
                
                if error == nil {
                    let passLib = PKPassLibrary()
                    //获得已经存在的Pass
                    let oldPass = passLib.passWithPassTypeIdentifier("pass.com.51work6.boarding-pass", serialNumber: SerialNumber)
                    //判断是否已经存在旧的Pass
                    if oldPass != nil {
                        //替换就的Pass
                        passLib.replacePassWithPass(newPass)
                    } else {
                        let addViewController = PKAddPassesViewController(pass: newPass)
                        addViewController.delegate = self
                        self.presentViewController(addViewController, animated: true, completion: nil)
                    }
                } else {
                    NSLog("下载失败。")
                    let alertView = UIAlertView(title: "错误信息", message: "用户不存在，请到51work6.com注册。", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
            }, errorHandler: { (operation, error) -> Void in
                NSLog("%@",error!.localizedDescription)
        })
        engine.enqueueOperation(op)
    }
    
}

