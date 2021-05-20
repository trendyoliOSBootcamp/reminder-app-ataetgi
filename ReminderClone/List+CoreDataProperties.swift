//
//  List+CoreDataProperties.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//
//

import CoreData
import UIKit

extension List {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var color: UIColor
    @NSManaged public var icon: String
    @NSManaged public var name: String
    @NSManaged public var date: Date
    @NSManaged public var reminders: NSOrderedSet?

}

// MARK: Generated accessors for reminders
extension List {

    @objc(insertObject:inRemindersAtIndex:)
    @NSManaged public func insertIntoReminders(_ value: Reminder, at idx: Int)

    @objc(removeObjectFromRemindersAtIndex:)
    @NSManaged public func removeFromReminders(at idx: Int)

    @objc(insertReminders:atIndexes:)
    @NSManaged public func insertIntoReminders(_ values: [Reminder], at indexes: NSIndexSet)

    @objc(removeRemindersAtIndexes:)
    @NSManaged public func removeFromReminders(at indexes: NSIndexSet)

    @objc(replaceObjectInRemindersAtIndex:withObject:)
    @NSManaged public func replaceReminders(at idx: Int, with value: Reminder)

    @objc(replaceRemindersAtIndexes:withReminders:)
    @NSManaged public func replaceReminders(at indexes: NSIndexSet, with values: [Reminder])

    @objc(addRemindersObject:)
    @NSManaged public func addToReminders(_ value: Reminder)

    @objc(removeRemindersObject:)
    @NSManaged public func removeFromReminders(_ value: Reminder)

    @objc(addReminders:)
    @NSManaged public func addToReminders(_ values: NSOrderedSet)

    @objc(removeReminders:)
    @NSManaged public func removeFromReminders(_ values: NSOrderedSet)

}

extension List : Identifiable {

}

@objc(UIColorValueTransformer)
final class ColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self))

    // 2. Make sure `UIColor` is in the allowed class list.
    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
