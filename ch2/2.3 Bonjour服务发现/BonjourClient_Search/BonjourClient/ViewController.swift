//
//  ViewController.swift
//  BonjourClient
//
//  Created by 关东升 on 15/6/5.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import UIKit

let BUFFER_SIZE = 1024

class ViewController: UIViewController, NSStreamDelegate {
    
    var flag = -1 //操作标志 0为发送 1为接收
    
    var client : Client!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    var inputStream : NSInputStream?
    var outputStream : NSOutputStream?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client = Client()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendData(sender: AnyObject) {
        flag = 0
        self.initNetworkCommunication()
    }
    
    @IBAction func receiveData(sender: AnyObject) {
        flag = 1
        self.initNetworkCommunication()
    }
    
    private func initNetworkCommunication() {
        
        for service in self.client.services {
            if "tony" == service.name {
                
                var inputStream: NSInputStream?
                var outputStream: NSOutputStream?
                let status = service.getInputStream(&inputStream, outputStream: &outputStream)
                if !status {
                    NSLog("连接服务器失败.")
                    return
                }
                self.inputStream = inputStream
                self.outputStream = outputStream
                                
                self.inputStream!.delegate = self
                self.inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
                self.inputStream!.open()
                
                self.outputStream!.delegate = self
                self.outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
                self.outputStream!.open()
                
                break
            }
        }
    }
    
    private func close() {
        self.outputStream!.close()
        self.outputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.outputStream!.delegate = nil
        
        self.inputStream!.close()
        self.inputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.inputStream!.delegate = nil
    }
    
    // MARK: --实现委托协议NSStreamDelegate
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        var event : String?
        
        switch eventCode {
        case NSStreamEvent.None:
            event = "NSStreamEventNone"
        case NSStreamEvent.OpenCompleted:
            event = "NSStreamEventOpenCompleted"
        case NSStreamEvent.HasBytesAvailable:
            event = "NSStreamEventHasBytesAvailable"
            
            if flag == 1 && aStream == self.inputStream {
                
                var input = NSMutableData()
                
                var buf = UnsafeMutablePointer<UInt8>.alloc(BUFFER_SIZE)
                var len = 0
                
                while self.inputStream!.hasBytesAvailable {
                    len = self.inputStream!.read(buf, maxLength: BUFFER_SIZE)
                    if len > 0 {
                        input.appendBytes(buf, length: len)
                    }
                }
                var resultstring = NSString(data: input, encoding: NSUTF8StringEncoding)
                NSLog("接收:%@", resultstring!)
                self.message.text = resultstring! as String
            }
            
        case NSStreamEvent.HasSpaceAvailable:
            event = "NSStreamEventHasSpaceAvailable"
            
            if flag == 0 && aStream == self.outputStream {
                //输出
                var sendString : String = self.textField.text
                var data = sendString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
                
                self.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                
                self.close()
            }
            
        case NSStreamEvent.ErrorOccurred:
            event = "NSStreamEventErrorOccurred"
            self.close()
        case NSStreamEvent.EndEncountered:
            event = "NSStreamEventEndEncountered"
            NSLog("Error:%d:%@", aStream.streamError!.code, aStream.streamError!.localizedDescription)
        default:
            self.close()
            event = "Unknown"
        }
        
        NSLog("event------%@", event!)
        
    }
    
}
