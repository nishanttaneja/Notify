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
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension NFCDGroup {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: NFCDGroupItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: NFCDGroupItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension NFCDGroup : Identifiable {

}
