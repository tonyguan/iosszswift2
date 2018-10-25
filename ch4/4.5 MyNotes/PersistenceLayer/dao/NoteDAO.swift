//
//  NoteDAO.swift
//  MyNotes
//
//  Created by 关东升 on 2014-10-18.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
//

import Foundation
import CloudKit

class NoteDAO {
    
    var container : CKContainer!
    var database :  CKDatabase!
    
    class var sharedInstance: NoteDAO {
        struct Static {
            static var instance: NoteDAO?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            
            var dao = NoteDAO()
            dao.container = CKContainer.defaultContainer()
            dao.database = dao.container.publicCloudDatabase //container.privateCloudDatabase
            
            Static.instance = dao
            
        }
        return Static.instance!
    }
    
    //插入Note方法
    func create(model: Note) -> Int {
        
        var record = CKRecord(recordType: "Note")
        record.setObject(model.content, forKey: "content")
        record.setObject(model.date, forKey: "date")
        
        self.database.saveRecord(record, completionHandler: { (recd, error) -> Void in
            if error != nil {
                NSLog("error: %@", error)
            } else {
                NSLog("插入数据成功。")
            }
        })
        
        return 0
    }
    
    //删除Note方法
    func remove(model: Note) -> Int {
        
        let predicate = NSPredicate(format: "date = %@", model.date)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { record in
            self.database.deleteRecordWithID(record.recordID, completionHandler: { (recd, error) -> Void in
                if error != nil {
                    NSLog("error: %@", error)
                } else {
                    NSLog("删除数据成功。")
                }
            })
        }
        //执行查询操作
        self.database.addOperation(queryOperation)
        
        return 0
    }
    
    //修改Note方法
    func modify(model: Note) -> Int {
        
        let predicate = NSPredicate(format: "date = %@", model.date)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { record in
            record.setObject(model.content, forKey: "content")
            
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            
            modifyOperation.perRecordCompletionBlock = { (recd, error) -> Void in
                if error != nil {
                    NSLog("error: %@", error)
                } else {
                    NSLog("修改数据成功。")
                }
            }
            //执行修改操作
            self.database.addOperation(modifyOperation)
        }
        //执行查询操作
        self.database.addOperation(queryOperation)
        
        return 0
    }
    
    //查询所有数据方法
    func findAll() {
        
        var listData = NSMutableArray()
        
        let predicate = NSPredicate(value: true)//不设置查询条件
        let query = CKQuery(recordType: "Note", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        //初始化QueryOperation
        let queryOperation = CKQueryOperation(query: query)
        //当提取数据时候设置
        queryOperation.recordFetchedBlock = { record in
            let content = record.objectForKey("content") as! String
            let date = record.objectForKey("date") as! NSDate

            var note = Note(date: date, content:content)
            listData.addObject(note)
        }
    
        queryOperation.queryCompletionBlock = { (cursor, error) in
            if error != nil {
                NSLog("error: %@", error)
            } else {
                //投送通知更新UI
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadViewNotification", object: listData)
                })
            }
        }
        
        //执行查询操作
        self.database.addOperation(queryOperation)

    }
    
    //按照主键查询数据方法
    func findById(model: Note)  {
        
        var note : Note!
        
        let predicate = NSPredicate(value: true)//不设置查询条件
        let query = CKQuery(recordType: "Note", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        //初始化QueryOperation
        let queryOperation = CKQueryOperation(query: query)
        //当提取数据时候设置
        queryOperation.recordFetchedBlock = { record in
            let content = record.objectForKey("content") as! String
            let date = record.objectForKey("date") as! NSDate
            
            note = Note(date: date, content:content)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) in
            if error != nil {
                NSLog("error: %@", error)
            } else {
                //投送通知更新UI
            }
        }
        
        //执行查询操作
        self.database.addOperation(queryOperation)

    }
    
}
