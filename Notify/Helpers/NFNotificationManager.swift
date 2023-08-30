//
//  NFNotificationManager.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UserNotifications

final class NFNotificationManager {
    static let shared = NFNotificationManager()
    private init() { }
    
    func requestNotificationAuthorisation() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                debugPrint(#function, error)
            }
        }
    }
    
    func scheduledRecurringRandomNotifications(forGroup group: NFGroup) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingRequests in
            let requestsToRemove = pendingRequests.filter({ $0.identifier.contains(group.id+"_REQUEST_") }).compactMap({ $0.identifier })
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestsToRemove)
        }
        UNUserNotificationCenter.current().getDeliveredNotifications { deliveredRequests in
            let requestsToRemove = deliveredRequests.filter({ $0.request.identifier.contains(group.id+"_REQUEST_") }).compactMap({ $0.request.identifier })
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: requestsToRemove)
        }
        for index in (0..<group.items.count).reversed() {
            let item = group.items[index]
            let content = UNMutableNotificationContent()
            content.title = group.title
            content.body = item.title
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.month, .day, .hour, .minute], from: group.date.advanced(by: 60*60*24*TimeInterval(index))), repeats: false)
            let request = UNNotificationRequest(identifier: group.id+"_REQUEST_"+item.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                guard let error else { return }
                debugPrint(#function, error)
            }
        }
    }
}
