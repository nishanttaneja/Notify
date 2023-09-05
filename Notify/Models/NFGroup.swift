//
//  NFGroup.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import Foundation

enum NFGroupNotificationRepeatType: TimeInterval {
    case minutely = 60, hourly = 3600, daily = 86400
}

struct NFGroup {
    let id: String
    var title: String
    var date: Date
    var alerts: Bool = false
    var repeatType: NFGroupNotificationRepeatType
    var items: [NFGroupItem]
}

struct NFGroupItem {
    let id: String
    var title: String
}
extension NFGroupItem: Equatable { }
