//
//  NFCDGroup+CoreDataProperties.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//
//

import Foundation
import CoreData


extension NFCDGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NFCDGroup> {
        return NSFetchRequest<NFCDGroup>(entityName: "NFCDGroup")
    }

    @NSManaged public var alerts: Bool
    @NSManaged public var date: Date?
    @NSManaged public var groupId: String?
    @NSManaged public var title: String?
    @NSManaged public var items: NSOrderedSet?

}

// MARK: Generated accessors for items
extension NFCDGroup {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: NFCDGroupItem, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [NFCDGroupItem], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: NFCDGroupItem)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [NFCDGroupItem])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: NFCDGroupItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: NFCDGroupItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)

}

extension NFCDGroup : Identifiable {

}
