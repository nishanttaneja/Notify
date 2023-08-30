//
//  NFCoreDataService.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import CoreData

enum NFCDError: Error {
    case notFound
}

final class NFCoreDataService {
    static let shared = NFCoreDataService()
    private init() { }
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotifyDB")
        container.loadPersistentStores { description, error in
            guard let error = error else { return }
            fatalError("Failed to load the persistent stores from model \"NotifyDB\"")
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension NFCoreDataService {
    func fetchGroups(completionHandler: @escaping (_ result: Result<[NFGroup], Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            let savedGroups = try viewContext.fetch(fetchRequest)
            let groupsToDisplay: [NFGroup] = savedGroups.compactMap { savedGroup in
                guard let id = savedGroup.groupId, let title = savedGroup.title, let date = savedGroup.date else { return nil }
                let items: [NFGroupItem] = (savedGroup.items?.allObjects as? [NFCDGroupItem] ?? []).compactMap({ savedItem in
                    guard let id = savedItem.itemId, let title = savedItem.title else { return nil }
                    return NFGroupItem(id: id, title: title)
                })
                return NFGroup(id: id, title: title, date: date, alerts: savedGroup.alerts, items: items)
            }
            completionHandler(.success(groupsToDisplay))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func fetchGroup(havingId id: String, completionHandler: @escaping (_ result: Result<NFGroup, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), id)
            guard let savedGroup = try viewContext.fetch(fetchRequest).first,
                  let id = savedGroup.groupId, let title = savedGroup.title, let date = savedGroup.date
            else { throw NFCDError.notFound }
            let items: [NFGroupItem] = (savedGroup.items?.allObjects as? [NFCDGroupItem] ?? []).compactMap({ savedItem in
                guard let id = savedItem.itemId, let title = savedItem.title else { return nil }
                return NFGroupItem(id: id, title: title)
            })
            let groupToDisplay = NFGroup(id: id, title: title, date: date, alerts: savedGroup.alerts, items: items)
            completionHandler(.success(groupToDisplay))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func insertGroup(_ group: NFGroup, completionHandler: @escaping (_ result: Result<NFGroup, Error>) -> Void) {
        do {
            viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let newGroup = NFCDGroup(context: viewContext)
            newGroup.groupId = group.id
            newGroup.title = group.title
            newGroup.date = group.date
            newGroup.alerts = group.alerts
            for item in group.items {
                let newItem = NFCDGroupItem(context: viewContext)
                newItem.itemId = item.id
                newItem.title = item.title
                newGroup.addToItems(newItem)
            }
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(group))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func insertGroupItem(_ item: NFGroupItem, inGroupHavingId groupId: String, completionHandler: @escaping (_ result: Result<NFGroupItem, Error>) -> Void) {
        do {
            viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), groupId)
            guard let savedGroup = try viewContext.fetch(fetchRequest).first else { throw NFCDError.notFound }
            let newItem = NFCDGroupItem(context: viewContext)
            newItem.itemId = item.id
            newItem.title = item.title
            savedGroup.addToItems(newItem)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(item))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func deleteGroup(_ group: NFGroup, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), group.id)
            guard let groupToDelete = try viewContext.fetch(fetchRequest).first else {
                throw NFCDError.notFound
            }
            viewContext.delete(groupToDelete)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(true))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func deleteGroupItem(_ item: NFGroupItem, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroupItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroupItem.itemId), item.id)
            guard let itemToDelete = try viewContext.fetch(fetchRequest).first else {
                throw NFCDError.notFound
            }
            viewContext.delete(itemToDelete)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(true))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
}
