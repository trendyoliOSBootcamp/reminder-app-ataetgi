//
//  Reminder+CoreDataProperties.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var done: Bool
    @NSManaged public var date: Date
    @NSManaged public var flag: Bool
    @NSManaged public var note: String
    @NSManaged public var priority: Int16
    @NSManaged public var title: String
    @NSManaged public var list: List
}

extension Reminder : Identifiable {

}
