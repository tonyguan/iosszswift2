//
//  ViewController.swift
//  NewsstandDemo
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
import NewsstandKit
import QuickLook

class ViewController: UIViewController,
        QLPreviewControllerDelegate,QLPreviewControllerDataSource {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentIssueName : String = ""
    
    let issueService  =  IssueService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //不可见
        self.button.alpha = 0.0
        self.progressView.alpha = 0.0
        
        self.activityIndicator.startAnimating()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCover:", name: UpdateCoverNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: UpdateUINotification, object: nil)
        
        self.issueService.addObserver(self, forKeyPath: "downloadProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func onclick(sender: AnyObject) {
        
        if self.button.tag == 1 { //打开处理
            let previewController = QLPreviewController()
            previewController.delegate = self
            previewController.dataSource = self
            
            self.presentViewController(previewController, animated: true, completion: nil)
        } else if self.button.tag == 2 {//下载处理
            self.button.alpha = 0.0
            self.progressView.alpha = 1.0
            
            //发出下载通知
            NSNotificationCenter.defaultCenter()
                .postNotificationName(DownloadNotification, object: self)
        }
    }

    //处理更新封面通知
    func updateCover(not : NSNotification) {
        
        let issues = not.object as? [[String : AnyObject]]
        let coverFilePath = issueService.getIssueCoverFilePathAtIndex(count(issues!) - 1)
        
        if let image = UIImage(contentsOfFile: coverFilePath) {
            self.imageView.image = image
        }
        self.activityIndicator.stopAnimating()
        
        self.button.alpha = 1.0
        self.button.setTitle("下载", forState: .Normal)
        self.button.tag = 2

    }
    //处理更新UI通知
    func updateUI(not : NSNotification) {
        
        let issues = not.object as? [[String : AnyObject]]
        currentIssueName = issues!.last!["ID"] as! String
        
        let issue = NKLibrary.sharedLibrary().issueWithName(currentIssueName)
        //只取最新的杂志
        let contentPath = issueService.downloadPathForIssue(issue)
        
        if NSFileManager.defaultManager().fileExistsAtPath(contentPath) && issue.status == NKIssueContentStatus.Available {
            self.button.setTitle("打开", forState: .Normal)
            self.button.tag = 1
        } else {
            self.button.setTitle("下载", forState: .Normal)
            self.button.tag = 2
        }
        
        if issue.status == NKIssueContentStatus.Downloading {
            self.button.alpha = 0.0
            self.progressView.alpha = 1.0
        } else {
            self.button.alpha = 1.0
            self.progressView.alpha = 0.0
        }
    }
    
    //MARK: --QuickLook
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController!) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        
        let issue = NKLibrary.sharedLibrary().issueWithName(currentIssueName)
        //只取最新的杂志
        let contentPath = issueService.downloadPathForIssue(issue)
        return NSURL(fileURLWithPath: contentPath)
    }
    
    //MARK: --观察issueService中下载进度
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        let value = change[NSKeyValueChangeNewKey]! as! Float
        self.progressView.progress = value
        
    }
}

