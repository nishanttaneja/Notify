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
