//
//  Tracker.swift
//  Tracker
//
//  Created by Владислав Усачев on 29.06.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
}

enum DayOfWeek: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
