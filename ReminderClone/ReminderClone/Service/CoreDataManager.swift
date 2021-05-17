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
    
    func createList(color: UIColor, icon: String, name: String, date: Date) {
        let context = persistentContainer.viewContext
        let list = List(context: context)
        list.color = color
        list.icon = icon
        list.name = name
        list.date = date
        saveContext() { _ in
            NotificationCenter.default.post(name: .updateList, object: nil)
        }
    }
    
    func createReminder(date: Date, flag: Bool, note: String, priority: Int16, title: String, list: List) {
        let context = persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.date = date
        reminder.flag = flag
        reminder.note = note
        reminder.priority = priority
        reminder.title = title
        reminder.list = list
        saveContext() { _ in
            NotificationCenter.default.post(name: .updateReminder, object: nil)
        }
    }
    
    func fetchLists() -> [List] {
        
        // attempt my core data fetch somehow...
        let context  = persistentContainer.viewContext
        
        let fetchRequest = List.createFetchRequest()
        
        do {
            let lists = try context.fetch(fetchRequest)
            return lists

        } catch let fetchErr {
            print("Failed to fetch companies", fetchErr)
            return []
        }
        
    }
    
    typealias SaveResult = (Error?) -> ()
    func saveContext(completion: SaveResult?) {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                completion?(nil)
            } catch {
                print("An error occured while saving: \(error)")
                completion?(error)
            }
        }
    }
}
