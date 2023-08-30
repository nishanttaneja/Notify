//
//  NFCDGroupItem+CoreDataProperties.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//
//

import Foundation
import CoreData


extension NFCDGroupItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NFCDGroupItem> {
        return NSFetchRequest<NFCDGroupItem>(entityName: "NFCDGroupItem")
    }

    @NSManaged public var itemId: String?
    @NSManaged public var title: String?
    @NSManaged public var group: NFCDGroup?

}

extension NFCDGroupItem : Identifiable {

}
