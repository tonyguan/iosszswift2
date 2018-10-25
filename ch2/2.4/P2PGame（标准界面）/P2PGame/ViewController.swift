//
//  ViewController.swift
//  P2PGame
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
import MultipeerConnectivity

let  GAMING = 0          //游戏进行中
let  GAMED  = 1          //游戏结束

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblPlayer2: UILabel!
    @IBOutlet weak var lblPlayer1: UILabel!
    
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnClick: UIButton!
    
    var timer : NSTimer!
    
    let serviceType = "P2PGame-service"
    
    var serviceBrowser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearUI()
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        
        self.serviceBrowser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.serviceBrowser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        self.assistant.start()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClick(sender: AnyObject) {
        
        if var count:Int = self.lblPlayer1.text?.toInt() {
            self.lblPlayer1.text = String(format: "%i", ++count)
            
            let sendStr = String(format:"{\"code\":%i,\"count\":%i}",GAMING,count)
            let data = sendStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            var error : NSError?
            self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error:  &error)
            
            if error != nil {
                NSLog("Error sending data:  %@", error!.localizedDescription)
            }
        }
    }
    
    
    @IBAction func connect(sender: AnyObject) {
        self.presentViewController(self.serviceBrowser, animated: true, completion: nil)
    }
    
    //清除UI画面上的数据
    func clearUI() {
        self.btnClick.enabled = false
        self.lblPlayer1.text = "0"
        self.lblPlayer2.text = "0"
        self.lblTimer.text = "30s"
        if self.timer != nil {
            self.timer.invalidate()
        }
    }
    
    //更新计时器
    func updateTimer() {
        
        var strRemainTime = self.lblTimer.text! as NSString
        let len = strRemainTime.length
        strRemainTime = strRemainTime.substringToIndex(len - 1)
        
        if var remainTime:Int = (strRemainTime as! String).toInt() {
            remainTime--
            //剩余时间为0 比赛结束
            if remainTime == 0 {
                
                var player1 = self.lblPlayer1.text?.toInt()
                var player2 = self.lblPlayer2.text?.toInt()
                var msg = "平手"
                
                if player1 > player2 {
                    msg = "我获胜"
                } else if player1 < player2 {
                    msg = "对手获胜"
                }
                
                let alerView = UIAlertView(title: "Game Over.", message:msg, delegate: self, cancelButtonTitle: "OK")
                alerView.show()
                
                self.clearUI()
                
            } else {
                self.lblTimer.text = String(format: "%is", remainTime)
            }
        }

    }
    
    //MARK: --实现UIAlertViewDelegate协议
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        self.btnClick.enabled = true
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "updateTimer",
            userInfo: nil, repeats: true)
        
    }
    
    //MARK: --实现MCSessionDelegate协议
    //端点状态变化
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
  
        var logmsg = ""
        
        switch state {
        case .NotConnected:
            logmsg = "断开连接"
            dispatch_async(dispatch_get_main_queue()) {
                self.btnClick.enabled = false
            }
        case .Connecting:
            logmsg = "连接中..."
        case .Connected:
            logmsg = "已连接"
            dispatch_async(dispatch_get_main_queue()) {
                self.btnClick.enabled = true
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                    selector: "updateTimer",
                    userInfo: nil, repeats: true)
            }
        }
        NSLog("Peer [%@] changed state to %@", peerID.displayName, logmsg)
    }
    
    //接收端点数据
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        let jsonObj = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.MutableContainers, error: nil) as! [String : AnyObject]
        
        let codeObj = jsonObj["code"] as! Int
        
        if codeObj == GAMING {
            let countObj = jsonObj["count"] as! Int
            dispatch_async(dispatch_get_main_queue()) {
                self.lblPlayer2.text = String(format: "%i", countObj)
            }
        } else if codeObj == GAMED {
            dispatch_async(dispatch_get_main_queue()) {
                self.clearUI()
            }
        }
    }
    
    // 接收端点数据流方式
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // 开始端点接收资源
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    // 接收端点资源完成
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    //MARK: --实现MCNearbyServiceBrowserDelegate协议
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

