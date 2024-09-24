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
        newTracker.isPinned = tracker.isPinned
        print(newTracker)
        
        return newTracker
    }
/*
    func deleteTracker(_ tracker: Tracker) -> Bool {
        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            
            if let trackerCoreData = trackerCoreDataArray.first {
                // Удаляем трекер
                context.delete(trackerCoreData)
                
                // Сохраняем изменения
                try context.save()
                print("Tracker deleted successfully")
                return true
            } else {
                print("Tracker not found")
                return false
            }
        } catch {
            print("Failed to delete tracker: \(error)")
            return false
        }
    }
*/
    func fetchTracker2() -> [TrackerCD] {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
      let trackerCoreDataArray = try! managedContext.fetch(fetchRequest)
      return trackerCoreDataArray
    }
    
    func deleteTracker(tracker: Tracker) {
      let targetTrackers = fetchTracker2()
      if let index = targetTrackers.firstIndex(where: {$0.id == tracker.id}) {
        context.delete(targetTrackers[index])
      }
    }
    
    func updateTracker(tracker: Tracker) {
        let targetTrackers = fetchTracker2()
        if let index = targetTrackers.firstIndex(where: {$0.id == tracker.id}) {
            targetTrackers[index].title = tracker.title
            targetTrackers[index].color = UIColorMarshalling.hexString(from: tracker.color)
            targetTrackers[index].emoji = tracker.emoji
            targetTrackers[index].schedule = tracker.schedule as NSArray?
            targetTrackers[index].category?.title = tracker.trackerCategory
            targetTrackers[index].isPinned = tracker.isPinned
            
            do {
                try context.save()
            } catch {
                print("Failed to update tracker: \(error)")
            }
        }
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
                    schedule: trackerCoreData.schedule as? [DayOfWeek] ?? [], 
                    trackerCategory: trackerCoreData.category?.title ?? "",
                    isPinned: trackerCoreData.isPinned
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
        return Tracker(id: id, title: title, color: UIColorMarshalling.color(from: color), emoji: emoji, schedule: trackersCoreData.schedule as? [DayOfWeek] ?? [], trackerCategory: trackersCoreData.category?.title ?? "", isPinned: trackersCoreData.isPinned)
    }
    
    func pinOrUnpinTracker(tracker: Tracker, isPinned: Bool) {
        let targetTrackers = fetchTracker2()
        
        if let trackerToUpdate = targetTrackers.first(where: { $0.id == tracker.id }) {
            trackerToUpdate.isPinned = isPinned // Меняем только флаг isPinned
            
            do {
                try context.save() // Сохраняем изменения в контексте Core Data
                print("Tracker pin status updated successfully")
                print(trackerToUpdate.isPinned)
            } catch {
                print("Failed to update tracker pin status: \(error)")
            }
        }
    }
}

