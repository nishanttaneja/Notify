//
//  NFGroup.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import Foundation

struct NFGroup {
    let id: String
    var title: String
    var date: Date
    var alerts: Bool = false
    var items: [NFGroupItem]
}

struct NFGroupItem {
    let id: String
    var title: String
}
extension NFGroupItem: Equatable { }

extension NFGroup {
    static let mockData: [NFGroup] = [
        NFGroup(id: "1", title: "Atomic Habits", date: .init(timeIntervalSince1970: 4000), items: [
            .init(id: "1.1", title: "Habits are the compound interest of self-improvement. Getting 1 percent better everyday counts for a lot in the long-run."),
            .init(id: "1.2", title: "Habits are a double -edged sword. They can work for you or against you, which is why understanding is details is essential."),
            .init(id: "1.3", title: "Small changes often appear to make no difference until you cross a critical threshold. The most powerful outcomes of any compounding process are delayed. You need to be patient."),
            .init(id: "1.4", title: "You do not rise to the level of your goals. You fall to the level of your systems.")
        ]),
        NFGroup(id: "2", title: "The Psychology of Money", date: .init(timeIntervalSince1970: 9000), items: [
            .init(id: "2.1", title: "Until you make the unconscious conscious, it will direct your life and you will call it fate.")
        ])
    ]
}
