//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Владислав Усачев on 14.08.2024.
//

import Foundation
import CoreData

@objc (DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    // тут будем писать код транформации
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [DayOfWeek] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([DayOfWeek].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
