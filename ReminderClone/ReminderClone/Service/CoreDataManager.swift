//
//  CoreDataManager.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//

import UIKit
import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReminderClone")
        container.loadPersistentStores { (storeDesc, error) in
            if let error = error {
                fatalError("Loading of store failed: \(error)")
            }
        }
        return container
    }()
    
    @discardableResult
    func createList(color: UIColor, icon: String, name: String, date: Date) -> (type: List?, error: Error?) {
        let context = persistentContainer.viewContext
        let list = List(context: context)
        list.color = color
        list.icon = icon
        list.name = name
        list.date = date
        return saveContext(list)
    }
    
    @discardableResult
    func createReminder(date: Date, flag: Bool, note: String, priority: Int16, title: String, list: List) -> (type: Reminder?, error: Error?)  {
        let context = persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.date = date
        reminder.flag = flag
        reminder.note = note
        reminder.priority = priority
        reminder.title = title
        reminder.list = list
        return saveContext(reminder)
    }
    
    
    func saveContext<T>(_ object: T? = nil) -> (type: T?, error: Error?) {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                if object is List {
                    NotificationCenter.default.post(name: .createList, object: nil)
                } else if object is Reminder {
                    NotificationCenter.default.post(name: .createReminder, object: nil)
                }
                return (object, nil)
            } catch {
                print("An error occured while saving: \(error)")
                return (nil, error)
            }
        }
        return (nil, nil)
    }
}
