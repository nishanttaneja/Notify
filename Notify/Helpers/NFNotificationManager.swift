//
//  NFNotificationManager.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UserNotifications
import EventKit

final class NFNotificationManager {
    static let shared = NFNotificationManager()
    private init() { }
    
    func requestNotificationAuthorisation() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
//            guard let error else { return }
//            debugPrint(#function, error)
//        }
//        eventStore.requestAccess(to: .reminder) { granted, error in
//            guard let error else { return }
//            debugPrint(#function, error)
//        }
    }
    
    private let eventStore = EKEventStore()
    
    func scheduledRecurringRandomNotifications(forGroup group: NFGroup) {
//        removeAllNotifications(forGroup: group)
//        for (index, item) in group.items.enumerated() {
//            guard index < 4 else { return }
//            let content = UNMutableNotificationContent()
//            content.title = group.title
//            content.body = item.title
//            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: group.date.advanced(by: group.repeatType.rawValue*TimeInterval(index)))
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//            let request = UNNotificationRequest(identifier: group.id+"_REQUEST_"+item.id, content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request) { error in
//                guard let error else { return }
//                debugPrint(#function, error)
//            }
//        }
    }
    
    func removeAllNotifications(forGroup group: NFGroup) {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingRequests in
//            let requestsToRemove = pendingRequests.filter({ $0.identifier.contains(group.id+"_REQUEST_") }).compactMap({ $0.identifier })
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestsToRemove)
//        }
//        UNUserNotificationCenter.current().getDeliveredNotifications { deliveredRequests in
//            let requestsToRemove = deliveredRequests.filter({ $0.request.identifier.contains(group.id+"_REQUEST_") }).compactMap({ $0.request.identifier })
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: requestsToRemove)
//        }
    }
}
