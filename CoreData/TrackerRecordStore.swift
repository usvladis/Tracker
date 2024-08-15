//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Владислав Усачев on 14.08.2024.
//

import CoreData
import UIKit


final class TrackerRecordStore {

  private let context: NSManagedObjectContext

  convenience init() {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    self.init(context: context)
  }

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func addNewRecord(from trackerRecord: TrackerRecord) {
    guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCD", in: context) else { return }
    let newRecord = TrackerRecordCD(entity: entity, insertInto: context)
    newRecord.id = trackerRecord.trackerId
    newRecord.date = trackerRecord.date
    do {
        try context.save()  // Save the context after adding the tracker
    } catch {
        print("Failed to save context: \(error)")
    }
  }

  func fetchAllRecords() -> [TrackerRecord] {
    let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
    do {
      let trackerRecords = try context.fetch(fetchRequest)
      return trackerRecords.map { TrackerRecord(trackerId: $0.id ?? UUID(), date: $0.date ?? Date()) }
    } catch {
      print("Failed to fetch tracker records: \(error)")
      return []
    }
  }

  func deleteRecord(for trackerRecord: TrackerRecord) {
      let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.trackerId as CVarArg, trackerRecord.date as CVarArg)
      do {
          let results = try context.fetch(fetchRequest)
          if let recordToDelete = results.first {
              context.delete(recordToDelete)
              try context.save()
              print("Record deleted: \(trackerRecord)")  // Log for debugging
          } else {
              print("Record not found: \(trackerRecord)")  // Log if record not found
          }
      } catch {
          print("Failed to delete record: \(error)")
      }
  }
}

