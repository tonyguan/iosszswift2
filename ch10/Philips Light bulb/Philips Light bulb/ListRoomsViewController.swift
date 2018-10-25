//
//  ListRoomsViewController.swift
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

class ListRoomsViewController: UITableViewController, HMHomeDelegate {
    
    var home: HMHome!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        home.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home.rooms.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let room = home.rooms[indexPath.row] as! HMRoom
        cell.textLabel!.text = room.name
        
        return cell
    }
    
    //MARK: --实现数据源协议
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let room = home.rooms[indexPath.row] as! HMRoom
            home.removeRoom(room, completionHandler: { (error) -> Void in
                
                if error != nil {
                    NSLog("error : %@", error)
                } else  {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            })
        }
    }
    
    //MARK: --实现HMHomeDelegate协议
    func home(home: HMHome, didAddRoom room: HMRoom!) {
         NSLog("一个房间被创建。")
    }
    
    func home(home: HMHome, didRemoveRoom room: HMRoom!) {
        NSLog("一个房间被删除。")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "addRoom"{
            
            let navController = segue.destinationViewController as! UINavigationController
            let addRoomViewController = navController.topViewController as! AddRoomViewController
            addRoomViewController.home = home
            
        } else if segue.identifier == "showDetailRoom" {
            
            let detailRoomViewController = segue.destinationViewController as! DetailRoomViewController
            detailRoomViewController.home = home
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            detailRoomViewController.room = home.rooms[indexPath.row] as! HMRoom
        }
    }
    
}
