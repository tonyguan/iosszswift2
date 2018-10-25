//
//  IssueService.swift
//  NewsstandDemo
//
//  Created by 关东升 on 15/7/22.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import Foundation
import NewsstandKit

//继续下载期刊通知
let ResumeDownloadNotification  = "com.51work6.newsstand.ResumeDownloadNotification"

//下载期刊通知
let DownloadNotification  = "com.51work6.newsstand.DownloadNotification"

//更新封面通知
let UpdateCoverNotification = "com.51work6.newsstand.UpdateCoverNotification"

//更新UI通知
let UpdateUINotification = "com.51work6.newsstand.UpdateUINotification"


let DOWNLOAD_PATH = "/service/newsstand/Issues.php"
let HOST = "51work6.com"
let USER_ID = "test89111@51work6.com"

class IssueService: NSObject, NSURLConnectionDownloadDelegate {
    
    //下载进度
    dynamic var downloadProgress : Float = 0.0
    //从服务器取得的最新杂志列表
    var issues : [[String : AnyObject]]! //数组里套字典[String : AnyObject]
    //请求队列
    
    override init() {
        super.init()
        
        //注册下载通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "download:", name: DownloadNotification, object: nil)
        
        //注册继续下载通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeDownload:", name: ResumeDownloadNotification, object: nil)
        
        self.start()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //开始处理方法
    func start() {
        
        var path = DOWNLOAD_PATH
        path = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var param = ["email": USER_ID]
        
        var engine = MKNetworkEngine(hostName: HOST, customHeaderFields: nil)
        var op = engine.operationWithPath(path, params: param, httpMethod:"POST")
        
        op.addCompletionHandler({ (operation) -> Void in
            
            let data  = operation.responseData()
            let str =  operation.responseString()
            //NSLog("JSON String : %@", str)
            
            var error : NSError?
            
            let resDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)  as! [String : AnyObject]
            
            if error != nil {
                NSLog("%@",error!.localizedDescription)
            } else {
                self.issues = resDict["issues"] as! [[String : AnyObject]]
                //添加报刊杂志到NSLibrary库
                self.addIssuesInNewsstand()
                //下载报刊杂志封面
                self.downloadIssuesCover()
            }
            
            }, errorHandler: { (operation, error) -> Void in
                NSLog("%@",error!.localizedDescription)
        })
        engine.enqueueOperation(op)
    }
    
    //添加报刊杂志到NSLibrary库
    func addIssuesInNewsstand() {
        
        let nkLib = NKLibrary.sharedLibrary()
        
        for item in self.issues {
            
            if let id = item["ID"] as? String  {
                //通过ID查找报刊杂志实例
                var nkIssue = nkLib.issueWithName(id)
                
                if nkIssue == nil {//没有找到报刊杂志实例
                    let df = NSDateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if let strDate : String = item["ReleaseDate"] as? String  {
                        let date = df.dateFromString(strDate)
                        //创建报刊杂志实例
                        nkIssue = nkLib.addIssueWithName(id, date: date)
                    }
                }
                NSLog("报刊杂志实例: %@",nkIssue)
            }
        }
    }
    
    // 下载报刊杂志封面
    func downloadIssuesCover() {
        
        //保留上一个Operation
        var previousOp : MKNetworkOperation!
        //请求线程数
        var queueRequestsCount = count(self.issues)
        
        var downlaodFileCount = 0
        
        for (index, item) in enumerate(self.issues) {
            
            let fileName = String(format: "issue%i.png", (index+1))
            let coverFilePath = applicationDocumentsDirectoryFile(fileName)
            //文件不存在，则下载
            if !NSFileManager.defaultManager().fileExistsAtPath(coverFilePath) {
                
                downlaodFileCount++
                
                var path = String(format: "/service/newsstand/issue%i.png", (index+1))
                
                path = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                var param = ["email": USER_ID]
                
                var engine = MKNetworkEngine(hostName: HOST, customHeaderFields: nil)
                var op = engine.operationWithPath(path, params: param, httpMethod:"POST")
                
                var os = NSOutputStream(toFileAtPath: coverFilePath, append: false)
                
                op.addDownloadStream(os)
                
                op.onDownloadProgressChanged { (progress) -> Void in
                    NSLog("download %i progress: %.2f%%", (index+1), progress*100.0)
                }
                
                if previousOp != nil {
                     //与上一个Operation建立依赖关系
                     previousOp.addDependency(op)
                }
                
                op.addCompletionHandler({ (operation) -> Void in
                    NSLog("download  %i progress: 100%%",(index+1))
                    NSLog("download file finished!")
                    //保留上一个Operation
                    previousOp = op
                    
                    if queueRequestsCount == (index+1) {//全部请求结束
                        
                        //取出最后的杂志封面更新UI
                        NSLog("杂志封面 : %@", coverFilePath)
                        if let image = UIImage(contentsOfFile: coverFilePath) {
                            UIApplication.sharedApplication().setNewsstandIconImage(image)
                        }
                        //更新封面
                        NSNotificationCenter.defaultCenter().postNotificationName(UpdateCoverNotification, object: self.issues)
                    }
                    
                }, errorHandler: { (operation, error) -> Void in
                    NSLog("%@",error!.localizedDescription)
                })
                engine.enqueueOperation(op)
            }
        }
        
        //没有杂志下载直接更新封面
        if  downlaodFileCount == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName(UpdateCoverNotification, object: self.issues)
        }
        
    }
    
    //处理下载通知
    func download(not : NSNotification) {
        //取最新的杂志
        let nkIssue  = self.getIssueAtIndex(count(self.issues) - 1)
        let downloadURLStr = issues!.last!["DownloadURL"] as! String

        if nkIssue.status != NKIssueContentStatus.Downloading {
            let downloadURL = NSURL(string: downloadURLStr)
            var req = NSURLRequest(URL: downloadURL!)
            var asset = nkIssue.addAssetWithRequest(req)
            asset.downloadWithDelegate(self)
        }
    }
    
    //处理断点续传下载通知
    func resumeDownload(not : NSNotification) {
        // 处理应用程序终止时候未下载完成的处理。
        let nkLib = NKLibrary.sharedLibrary()
        for asset in nkLib.downloadingAssets {
            let nkIssue = asset.issue
            NSLog("继续下载 issue %@ (asset ID: %@)",nkIssue!.name,asset.identifier)
            asset.downloadWithDelegate(self)
        }
    }
    
    //通过索引获得杂志内容目录
    func getIssueContentPathAtIndex(index : Int) -> String {
        let nkIssue  = self.getIssueAtIndex(index)
        return self.downloadPathForIssue(nkIssue)
    }
    
    //通过索引获得杂志实例
    func getIssueAtIndex(index : Int) -> NKIssue {
        
        let nkLib = NKLibrary.sharedLibrary()
        let item = self.issues[index]
        let id = item["ID"] as? String
        let nkIssue = nkLib.issueWithName(id)
        return nkIssue
    }
    
    //通过索引获得杂志封面
    func getIssueCoverFilePathAtIndex(index : Int) -> String {
        
        let fileName = String(format: "issue%i.png", (index+1))
        let coverFilePath = applicationDocumentsDirectoryFile(fileName)
        
        return coverFilePath
    }
    
    //获得下载杂志路径
    func downloadPathForIssue(nkIssue : NKIssue) -> String {
        let nkIssue  = nkIssue.contentURL.path?.stringByAppendingPathComponent("magazine.pdf")
        return nkIssue!
    }
    
    //MARK: --NSURLConnectionDownloadDelegate
    func connection(connection: NSURLConnection, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, expectedTotalBytes: Int64) {
       
        downloadProgress =  Float(totalBytesWritten) / Float(expectedTotalBytes)
        
        NSLog("下载进度: %.2f%%", downloadProgress * 100.0)
        
    }
    
    func connectionDidResumeDownloading(connection: NSURLConnection, totalBytesWritten: Int64, expectedTotalBytes: Int64) {
        
        downloadProgress =  Float(totalBytesWritten) / Float(expectedTotalBytes)
        
        NSLog("下载进度: %.2f%%", downloadProgress * 100.0)
    }
    
    func connectionDidFinishDownloading(connection: NSURLConnection, destinationURL: NSURL) {
        
        let dnl = connection.newsstandAssetDownload
        let nkIssue = dnl.issue
        
        let contentPath = self.downloadPathForIssue(nkIssue)
        var moveError : NSError?
        NSLog("contentPath : %@",contentPath)
        
        NSFileManager.defaultManager().moveItemAtPath(destinationURL.path!, toPath: contentPath, error: &moveError)
        
        if (moveError != nil) {
            NSLog("文件拷贝失败 从 %@ 到 %@",destinationURL,contentPath)
        }        
        //更新UI
        NSNotificationCenter.defaultCenter().postNotificationName(UpdateUINotification, object: self.issues)
        
    }
    
    func applicationDocumentsDirectoryFile(fileName : String) ->String {
        let  documentDirectory: NSArray = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let path = documentDirectory[0].stringByAppendingPathComponent(fileName) as String
        return path
    }
}
