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
import CoreData

class NoteDAO : CoreDataDAO {
    
    let DBFILE_NAME = "NotesList.sqlite3"
    var db:COpaquePointer = nil
    
    class var sharedInstance: NoteDAO {
        struct Static {
            static var instance: NoteDAO?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NoteDAO()
        }
        return Static.instance!
    }
    
    //插入Note方法
    func create(model: Note) -> Int {
        var cxt = self.managedObjectContext!
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext:cxt) as! NSManagedObject
        
        note.setValue(model.date, forKey: "date")
        note.setValue(model.content, forKey: "content")
        
        var error: NSError? = nil
        if cxt.hasChanges && !cxt.save(&error) {
            NSLog("插入数据失败: \(error), \(error!.userInfo)")
            return -1
        }
        return 0
    }
    
    //删除Note方法
    func remove(model: Note) -> Int {
        var cxt = self.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: cxt)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date =  %@", model.date)
        
        var error: NSError? = nil
        var listData = cxt.executeFetchRequest(fetchRequest, error: &error) as NSArray!
        
        if listData.count > 0 {
            var note = listData.lastObject as! NSManagedObject
            cxt.deleteObject(note)
            
            error = nil
            if cxt.hasChanges && !cxt.save(&error) {
                NSLog("删除数据失败: \(error), \(error!.userInfo)")
                return -1
            }
        }
        return 0
    }
    
    //修改Note方法
    func modify(model: Note) -> Int {
        var cxt = self.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: cxt)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date =  %@", model.date)
        
        var error: NSError? = nil
        var listData = cxt.executeFetchRequest(fetchRequest, error: &error) as NSArray!
        
        if listData.count > 0 {
            var note = listData.lastObject as! NSManagedObject
            note.setValue(model.content, forKey: "content")
            
            if cxt.hasChanges && !cxt.save(&error) {
                NSLog("修改数据失败: \(error), \(error!.userInfo)")
                return -1
            }
        }
        return 0
    }
    
    //查询所有数据方法
    func findAll() -> NSMutableArray {
        var cxt = self.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: cxt)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        var sortDescriptor = NSSortDescriptor(key:"date", ascending:true)
        var sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        var error: NSError? = nil
        var listData = cxt.executeFetchRequest(fetchRequest, error: &error) as NSArray!
        
        var resListData = NSMutableArray()
        
        for item in listData {
            var mo = item as! NSManagedObject
            
            var date = mo.valueForKey("date") as! NSDate!
            var content = mo.valueForKey("content") as! String!
            var note = Note(date: date, content: content)
            
            resListData.addObject(note)
            
        }
        
        return resListData
    }
    
    //按照主键查询数据方法
    func findById(model: Note) -> Note? {
        var cxt = self.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: cxt)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date =  %@", model.date)
        
        var error: NSError? = nil
        var listData = cxt.executeFetchRequest(fetchRequest, error: &error) as NSArray!
        
        if listData.count > 0 {
            var mo = listData.lastObject as! NSManagedObject
            var date = mo.valueForKey("date") as! NSDate!
            var content = mo.valueForKey("content") as! String!
            
            var note = Note(date: date, content: content)
            
            return note
        }
        return nil
    }
    
}
