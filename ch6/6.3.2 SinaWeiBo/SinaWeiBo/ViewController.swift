//
//  ViewController.swift
//  SinaWeiBo
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

import Social
import Accounts

class ViewController: UITableViewController {
    
    //查询返回的微博列表
    var listData :[AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UIRefreshControl
        var rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: "下拉刷新")
        rc.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = rc
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshTableView() {
        
        if (self.refreshControl?.refreshing == true) {
            self.refreshControl?.attributedTitle = NSAttributedString(string: "加载中...")
            
            let account = ACAccountStore()
            let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierSinaWeibo)
            
            account.requestAccessToAccountsWithType(accountType, options: nil, completion: { (granted, error) -> Void in
                
                if granted {
                    let arrayOfAccounts = account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        let weiboAccount = arrayOfAccounts.last as? ACAccount
                        
                        var parameters = ["count" : "20"]
                        let requestURL = NSURL(string: "https://api.weibo.com/2/statuses/user_timeline.json")
                        let request = SLRequest(forServiceType: SLServiceTypeSinaWeibo,
                            requestMethod: SLRequestMethod.GET,
                            URL: requestURL,
                            parameters: parameters)
                        
                        request.account = weiboAccount
                        
                        request.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                            
                            var err: NSError?
                            let jsonObj : [NSString : AnyObject] = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &err) as! [String : AnyObject]
                            
                            if err == nil {
                                self.listData = jsonObj["statuses"] as! [AnyObject]!
                                self.tableView.reloadData()
                            }
                            
                            NSLog("Weibo HTTP response: %i", urlResponse.statusCode)
                            //停止下拉刷新
                            self.refreshControl?.endRefreshing()
                            self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新")
                            
                        })
                        
                    }
                    
                }
            })
            
        }
    }
    
    // MARK: --Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.listData?.count {
            return count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let rowDict = self.listData[indexPath.row] as! [String : AnyObject]
        cell.textLabel?.text = rowDict["text"] as? String
        cell.detailTextLabel?.text = rowDict["created_at"] as? String
        
        return cell
    }
    
}