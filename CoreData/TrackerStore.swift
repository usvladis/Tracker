//
//  TrackerStore.swift
//  Tracker
//
//  Created by Владислав Усачев on 14.08.2024.
//

import CoreData
import UIKit

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(from tracker: Tracker) -> TrackerCD? {
        print("AddNewTracker is called")
        guard let trackerCoreData = NSEntityDescription.entity(forEntityName: "TrackerCD", in: context) else { return nil }
        let newTracker = TrackerCD(entity: trackerCoreData, insertInto: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.color = UIColorMarshalling.hexString(from: tracker.color)
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule as NSArray?
        print(newTracker)
        
        return newTracker
    }
    
    func fetchTracker() -> [Tracker] {
        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            let trackers = trackerCoreDataArray.map { trackerCoreData in
                return Tracker(
                    id: trackerCoreData.id ?? UUID(),
                    title: trackerCoreData.title ?? "",
                    color: UIColorMarshalling.color(from: trackerCoreData.color ?? ""),
                    emoji: trackerCoreData.emoji ?? "",
                    schedule: trackerCoreData.schedule as? [DayOfWeek] ?? []
                )
            }
            return trackers
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    func decodingTrackers(from trackersCoreData: TrackerCD) -> Tracker? {
        guard let id = trackersCoreData.id, let title = trackersCoreData.title,
              let color = trackersCoreData.color, let emoji = trackersCoreData.emoji else { return nil }
        return Tracker(id: id, title: title, color: UIColorMarshalling.color(from: color), emoji: emoji, schedule: trackersCoreData.schedule as? [DayOfWeek] ?? [])
    }
}

