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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard let error else { return }
            debugPrint(#function, error)
        }
    }
    
    func sendRandomNotification(id: String, title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            guard let error else { return }
            debugPrint(#function, error)
        }
    }
}
