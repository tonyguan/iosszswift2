//
//  SendViewController.swift
//  SinaWeiBo
//
//  Created by 关东升 on 15/7/21.
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

class SendViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var lblCharCounter: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender: AnyObject) {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierSinaWeibo)
        
        account.requestAccessToAccountsWithType(accountType, options: nil, completion: { (granted, error) -> Void in
            
            if granted {
                let arrayOfAccounts = account.accountsWithAccountType(accountType)
                
                if arrayOfAccounts.count > 0 {
                    let weiboAccount = arrayOfAccounts.last as? ACAccount
                    
                    var parameters = ["status" : self.textView.text]
                    let requestURL = NSURL(string: "https://api.weibo.com/2/statuses/update.json")
                    
                    let request = SLRequest(forServiceType: SLServiceTypeSinaWeibo,
                        requestMethod: SLRequestMethod.POST,
                        URL: requestURL,
                        parameters: parameters)
                    
                    request.account = weiboAccount
                    
                    request.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                        NSLog("Weibo HTTP response: %i", urlResponse.statusCode)
                    })
                    
                }
                
            }
        })

        //放弃第一响应者
        self.textView.resignFirstResponder()
        //关闭模态视图
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        //放弃第一响应者
        self.textView.resignFirstResponder()
        //关闭模态视图
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: --TextView 委托方法
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let content = self.textView.text
        var counter = 140 - count(content)
        
        if counter <= 0 {
            self.lblCharCounter.text = ""
            return false
        }
        self.lblCharCounter.text = String(format: "%i", counter)
        return true
    }
    

}
