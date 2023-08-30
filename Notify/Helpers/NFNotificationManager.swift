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
    func setReminder(id: String, date: Date, message: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Notify"
        notificationContent.body = message
        notificationContent.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute, .second], from: date), repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            guard let error else { return }
            debugPrint(#function, error)
        }
    }
}
