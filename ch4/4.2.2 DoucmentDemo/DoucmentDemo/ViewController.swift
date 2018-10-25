//
//  ViewController.swift
//  DoucmentDemo
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

let DeviceName = UIDevice.currentDevice().name

class ViewController: UIViewController {

    @IBOutlet weak var txtContent: UITextField!
    
    var myCloudDocument : MyCloudDocument!
    
    var query = NSMetadataQuery()
    
    //请求本地Ubiquity容器，从容器中获得Document目录URL
    lazy var ubiquitousDocumentsURL : NSURL? = {
        let fileManager = NSFileManager.defaultManager()
        var containerURL = fileManager.URLForUbiquityContainerIdentifier("iCloud.com.51work6.DoucmentDemo")
        NSLog("Ubiquity容器 : %@", containerURL!)
        containerURL = containerURL?.URLByAppendingPathComponent("Documents")
        return containerURL
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //为查询iCloud文件的变化，注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateUbiquitousDocuments:", name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateUbiquitousDocuments:", name: NSMetadataQueryDidUpdateNotification, object: nil)
        
        //注册文档状态变化通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resolveConflict:", name: UIDocumentStateChangedNotification, object: nil)
        
        //查询iCloud文件的变化
        if (self.ubiquitousDocumentsURL != nil) {
            self.query.predicate = NSPredicate(format: "%K like 'abc.txt'", NSMetadataItemFSNameKey)
            self.query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.query.enableUpdates()
        self.query.startQuery()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.query.disableUpdates()
        self.query.stopQuery()
    }


    
    //当iCloud中的文件变化时候调用
    func updateUbiquitousDocuments(notification : NSNotification) {
        //文件存在
        if self.query.results.count == 1 {
            let ubiquityURL  = self.query.results.last?.valueForAttribute(NSMetadataItemURLKey) as! NSURL
            
            self.myCloudDocument = MyCloudDocument(fileURL: ubiquityURL)
            self.myCloudDocument.openWithCompletionHandler({ (success) -> Void in
                if success {
                    NSLog("%@ : 打开iCloud文档", DeviceName)
                    if self.myCloudDocument.contents != nil {
                        self.txtContent.text = self.myCloudDocument.contents as! String
                    } else {
                        self.txtContent.text =  ""
                    }
                }
            })
        } else { //文件不存在
            NSLog("文件不存在")
            let documentiCloudPath = self.ubiquitousDocumentsURL?.URLByAppendingPathComponent("abc.txt")
            self.myCloudDocument = MyCloudDocument(fileURL: documentiCloudPath!)
            self.myCloudDocument.contents = self.txtContent.text
        }
        
        if self.myCloudDocument != nil {
            //注册CloudDocument对象到文档协调者，文档状态变化才能收到通知
            NSFileCoordinator.addFilePresenter(self.myCloudDocument)
        }
    }
    
    @IBAction func saveClick(sender: AnyObject) {
        self.myCloudDocument.contents = self.txtContent.text
        self.myCloudDocument.updateChangeCount(UIDocumentChangeKind.Done)
        self.txtContent.resignFirstResponder()
    }
    
    //文档冲突解决
    func resolveConflict(notification : NSNotification) {
        if self.myCloudDocument != nil
            && self.myCloudDocument.documentState == UIDocumentState.InConflict {
            NSLog("冲突发生")
            //文档冲突解决策略
            NSFileVersion.removeOtherVersionsOfItemAtURL(self.myCloudDocument.fileURL, error: nil)
            
            let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItemAtURL(self.myCloudDocument.fileURL)
            for item in conflictVersions! {
                let fileVersion = item as! NSFileVersion
                NSLog("fileVersion.name = %@",fileVersion.modificationDate!)
                fileVersion.resolved = true
            }
            self.myCloudDocument.contents = self.txtContent.text
            self.myCloudDocument.updateChangeCount(UIDocumentChangeKind.Done)
        }
        if self.myCloudDocument != nil {
            //从文档协调者中解除CloudDocument对象
            NSFileCoordinator.removeFilePresenter(self.myCloudDocument)
        }
    }
    
}

