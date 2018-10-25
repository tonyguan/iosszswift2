//
//  ViewController.swift
//  HomeKitDemo
//
//  Created by 关东升 on 15/7/29.
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

class ViewController: UITableViewController, HMHomeManagerDelegate {
    
    var homeManager = HMHomeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeManager.delegate = self
        self.navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: --实现表视图委托协议
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeManager.homes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let home = homeManager.homes[indexPath.row] as! HMHome
        cell.textLabel!.text = home.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let home = homeManager.homes[indexPath.row] as! HMHome
            homeManager.removeHome(home, completionHandler: { (error) -> Void in
                
                if error != nil {
                    NSLog("error : %@", error)
                } else  {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                
            })
        }
    }
    
    
    //MARK: --实现HMHomeManagerDelegate委托协议
    func homeManager(manager: HMHomeManager, didRemoveHome home: HMHome!) {
        NSLog("一个家庭被删除。")
    }
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        //NSLog("一个家庭被创建。")
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "addHome"{
            
            let navController = segue.destinationViewController as! UINavigationController
            let addHomeViewController = navController.topViewController as! AddHomeViewController
            addHomeViewController.homeManager = homeManager
        } else if segue.identifier == "showRooms"{
            
            let listRoomsViewController = segue.destinationViewController as! ListRoomsViewController
            
            let home = homeManager.homes[tableView.indexPathForSelectedRow()!.row]
                as! HMHome

            listRoomsViewController.home = home
        }
    }

}

