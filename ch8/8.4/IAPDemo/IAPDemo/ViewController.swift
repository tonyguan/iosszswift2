//
//  ViewController.swift
//  IAPDemo
//
//  Created by 关东升 on 15/7/24.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit
import StoreKit

let ProductInfo_PATH = "/service/ProductInfo.php"
let ValidationReceipt_PATH = "/service/verifyReceipt.php"

let HOST = "51work6.com"
let USER_ID = "test89111@51work6.com"

class ViewController: UITableViewController,
SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    //刷新按钮属性
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    //恢复按钮属性
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    //产品列表
    var skProducts : [SKProduct]!
    //数字格式
    var priceFormatter = NSNumberFormatter()
    //产品标识集合
    var productIdentifiers = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置数字格式
        self.priceFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        self.priceFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
 
        //从服务器读取应用内产品标识
        var path = ProductInfo_PATH
        path = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var param = ["email": USER_ID]
        
        var engine = MKNetworkEngine(hostName: HOST, customHeaderFields: nil)
        var op = engine.operationWithPath(path, params: param, httpMethod:"POST")
        
        op.addCompletionHandler({ (operation) -> Void in
            
            let data  = operation.responseData()
            let str =  operation.responseString()
            NSLog("JSON String : %@", str)
            
            var error : NSError?
            
            let resDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)  as! [String : AnyObject]
            
            if error != nil {
                NSLog("%@",error!.localizedDescription)
            } else {
                //成功
                let rc = resDict["ResultCode"] as? Int
                if rc == 0 {
                    NSLog("服务器查询产品信息成功。")
                    let resArray = resDict["Products"] as? [[String : String]]
                    
                    for product in resArray! {
                        let productId = product["id"]
                        self.productIdentifiers.append(productId!)
                    }
                } else {
                    NSLog("服务器查询产品信息失败。")
                    
                    let alertView = UIAlertView(title: "错误信息", message: "用户不存在，请到51work6.com注册。", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
            
            }, errorHandler: { (operation, error) -> Void in
                NSLog("%@",error!.localizedDescription)
        })
        engine.enqueueOperation(op)
        
        // 添加self作为交易观察者对象
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: --实现UITableViewDataSource协议
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.skProducts?.count {
            return count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let product = self.skProducts[indexPath.row]
        cell.textLabel?.text = product.localizedTitle
        self.priceFormatter.locale = product.priceLocale
        
        cell.detailTextLabel?.text = self.priceFormatter.stringFromNumber(product.price)
        
        //从应用设置文件中读取 购买信息
        let productPurchased = NSUserDefaults.standardUserDefaults().boolForKey(product.productIdentifier)
        if productPurchased {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.accessoryView = nil
        } else {
            let buttonUpImage = UIImage(named: "button_up.png")
            let buttonDownImage = UIImage(named: "button_down.png")
            
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            button.frame = CGRectMake(0.0, 0.0, buttonUpImage!.size.width, buttonUpImage!.size.height)
            button.setBackgroundImage(buttonUpImage, forState: .Normal)
            button.setBackgroundImage(buttonDownImage, forState: .Highlighted)
            
            button.setTitle("购买", forState: .Normal)
            button.tag = indexPath.row
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            cell.accessoryView = button
        }
        return cell
    }
    
    func buttonTapped(sender: AnyObject) {
        let buyButton = sender as? UIButton
        //通过按钮tag获得被点击按钮的索引，使用索引从数组中取出产品SKProduct对象
        let product = self.skProducts[buyButton!.tag] as SKProduct
        //获得产品的付款对象
        let payment = SKPayment(product: product)
        //把付款对象添加到付款队列中
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    //点击刷新按钮
    @IBAction func request(sender: AnyObject) {
        //检查设备是否有家长控制，禁止应用内购买
        if SKPaymentQueue.canMakePayments() {
            //没有设置可以请求应用购买信息
            let set = NSSet(array: self.productIdentifiers) as Set<NSObject>
            let request = SKProductsRequest(productIdentifiers: set)
            request.delegate = self
            request.start()
            
            self.navigationItem.prompt = "刷新中..."
            self.refreshButton.enabled = false
            self.restoreButton.enabled = false
            
        } else {
            //有设置请况下
            let alertView = UIAlertView(title: "访问限制",
                message: "您不能进行应用内购买！",
                delegate: nil,
                cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
    //点击恢复按钮
    @IBAction func restore(sender: AnyObject) {
        self.navigationItem.prompt = "恢复中..."
        self.refreshButton.enabled = false
        self.restoreButton.enabled = false
        
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    //MARK: --实现SKProductsRequestDelegate协议
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        NSLog("加载应用内购买产品...")
        
        self.navigationItem.prompt = nil
        self.refreshButton.enabled = true
        self.restoreButton.enabled = true
        
        self.skProducts = response.products as! [SKProduct]!
        
        for skProducts in self.skProducts {
            NSLog("找到产品: %@ %@ %0.2f", skProducts.productIdentifier, skProducts.localizedTitle, skProducts.price.floatValue)
        }
        self.tableView.reloadData()
    }
 
    
    //MARK: --实现SKPaymentTransactionObserver协议
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for item in transactions {
            let transaction = item as! SKPaymentTransaction
            
            switch transaction.transactionState {
            case .Purchasing: //交易中
                NSLog("交易中...")
            case .Purchased:    //交易完成
                self.completeTransaction(transaction)
            case .Failed:       //交易失败
                self.failedTransaction(transaction)
            case .Restored:     //交易恢复
                self.restoreTransaction(transaction)
            case .Deferred: //交易延期
                NSLog("交易延期")
            }
        }
    }
    
    //交易完成
    func completeTransaction(transaction : SKPaymentTransaction) {
        NSLog("交易完成...")
        
        self.validateReceiptForTransaction(transaction)
        //把交易从付款队列中移除
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
   }
    
    //交易恢复
    func restoreTransaction(transaction : SKPaymentTransaction) {
        NSLog("交易恢复...")
        
        self.navigationItem.prompt = nil
        self.refreshButton.enabled = true
        self.restoreButton.enabled = true
        
        self.validateReceiptForTransaction(transaction)
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    //交易失败
    func failedTransaction(transaction : SKPaymentTransaction) {
        NSLog("交易失败...")
        
        if let error = transaction.error {
            if error.code != SKErrorPaymentCancelled {
                switch (error.code) {
                case SKErrorUnknown:
                    NSLog("SKErrorUnknown")
                case SKErrorClientInvalid:
                    NSLog("SKErrorClientInvalid")
                case SKErrorPaymentCancelled:
                    NSLog("SKErrorPaymentCancelled")
                case SKErrorPaymentInvalid:
                    NSLog("SKErrorPaymentInvalid")
                case SKErrorPaymentNotAllowed:
                    NSLog("SKErrorPaymentNotAllowed")
                default:
                    NSLog("No Match Found for error")
                }
                NSLog("error.code %@", error.localizedDescription)
            }
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    //验证收据
    func validateReceiptForTransaction(transaction : SKPaymentTransaction) {
        
        let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL
        let receiptData = NSData(contentsOfURL: receiptUrl!)
        if receiptData == nil {
            return
        }
        let receiptBase64  = receiptData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
      
        var path = ValidationReceipt_PATH
        path = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var param = ["email": USER_ID]
        param["receipt"] = receiptBase64
        param["sandbox"] = "true"
        
        var engine = MKNetworkEngine(hostName: HOST, customHeaderFields: nil)
        var op = engine.operationWithPath(path, params: param, httpMethod:"POST")
        
        op.addCompletionHandler({ (operation) -> Void in
            
            let data  = operation.responseData()
            if data.length > 0 {
                let str =  operation.responseString()
                NSLog("JSON String : %@", str)
                
                var error : NSError?
                
                let resDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)  as! [String : AnyObject]
                
                if error != nil {
                    NSLog("%@",error!.localizedDescription)
                } else {
                    //成功
                    let rc = resDict["ResultCode"] as? Int
                    if rc == 0 {
                        NSLog("验证收据成功。")
                        self.provideContentForProductIdentifier(transaction.payment.productIdentifier)
                        //把交易从付款队列中移除
                        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                        
                    } else {
                        NSLog("验证收据失败。")
                    }
                }
            }
            }, errorHandler: { (operation, error) -> Void in
                NSLog("%@",error!.localizedDescription)
        })
        engine.enqueueOperation(op)
    }
    
    //购买成功
    func provideContentForProductIdentifier(productIdentifier : String) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
    }
    
}

