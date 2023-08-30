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
    var items: [String]
}

extension NFGroup: Equatable { }

extension NFGroup {
    static let mockData: [NFGroup] = [
        NFGroup(id: "1", title: "Atomic Habits", date: .init(timeIntervalSince1970: 4000), items: [
            "Habits are the compound interest of self-improvement. Getting 1 percent better everyday counts for a lot in the long-run.",
            "Habits are a double -edged sword. They can work for you or against you, which is why understanding is details is essential.",
            "Small changes often appear to make no difference until you cross a critical threshold. The most powerful outcomes of any compounding process are delayed. You need to be patient.",
            "You do not rise to the level of your goals. You fall to the level of your systems."
        ]),
        NFGroup(id: "2", title: "The Psychology of Money", date: .init(timeIntervalSince1970: 9000), items: [
            "Until you make the unconscious conscious, it will direct your life and you will call it fate."
        ])
    ]
}
