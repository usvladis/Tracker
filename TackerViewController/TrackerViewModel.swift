//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Владислав Усачев on 22.08.2024.
//

import Foundation

class TrackerViewModel {
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?(categories)
        }
    }
    
    var visibleTrackers: [TrackerCategory] = [] {
        didSet {
            onVisibleTrackersChanged?(visibleTrackers)
        }
    }
    
    var completedTrackers: [TrackerRecord] = [] {
        didSet {
            onCompletedTrackersChanged?(completedTrackers)
        }
    }
    
    var selectedDate = Date() {
        didSet {
            onSelectedDateChanged?(selectedDate)
            filterTrackersForCurrentDay()
        }
    }
    
    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onVisibleTrackersChanged: (([TrackerCategory]) -> Void)?
    var onCompletedTrackersChanged: (([TrackerRecord]) -> Void)?
    var onSelectedDateChanged: ((Date) -> Void)?
    
    init() {
        loadTrackersFromCoreData()
        filterTrackersForCurrentDay()
    }
    
    private func loadTrackersFromCoreData() {
        let storedTrackers = trackerStore.fetchTracker()
        let storedCategories = trackerCategoryStore.fetchAllCategories()
        let storedRecords = trackerRecordStore.fetchAllRecords()
        
        completedTrackers = storedRecords.map { TrackerRecord(trackerId: $0.trackerId, date: $0.date) }
        
        if !storedCategories.isEmpty {
            categories = storedCategories.compactMap { trackerCategoryStore.decodingCategory(from: $0) }
        } else {
            categories = [TrackerCategory(title: "Важное", trackers: storedTrackers)]
        }
        
        visibleTrackers = categories
        filterTrackersForCurrentDay()
    }
    
    func appendTrackerInVisibleTrackers(weekday: Int) {
        visibleTrackers.removeAll()
        var weekDayCase: DayOfWeek = .monday
        
        switch weekday {
        case 1:
            weekDayCase = .sunday
        case 2:
            weekDayCase = .monday
        case 3:
            weekDayCase = .tuesday
        case 4:
            weekDayCase = .wednesday
        case 5:
            weekDayCase = .thursday
        case 6:
            weekDayCase = .friday
        case 7:
            weekDayCase = .saturday
        default:
            break
        }
        
        guard let firstCategory = categories.first else {
            return
        }
        
        var uniqueTrackers = [UUID: Tracker]()
        for tracker in firstCategory.trackers {
            for day in tracker.schedule {
                if day == weekDayCase {
                    uniqueTrackers[tracker.id] = tracker
                }
            }
        }
        
        let trackers = Array(uniqueTrackers.values)
        if !trackers.isEmpty {
            let category = TrackerCategory(title: "Важное", trackers: trackers)
            visibleTrackers.append(category)
        }
    }
    
    func filterTrackersForCurrentDay() {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: selectedDate)
        
        appendTrackerInVisibleTrackers(weekday: dayOfWeek)
    }
    
    func toggleTrackerCompletion(for tracker: Tracker) {
        let today = Date()
        
        if Calendar.current.compare(selectedDate, to: today, toGranularity: .day) == .orderedDescending {
            return // Не разрешаем отмечать будущие даты
        }
        
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            let record = completedTrackers[index]
            completedTrackers.remove(at: index)
            trackerRecordStore.deleteRecord(for: record)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(record)
            trackerRecordStore.addNewRecord(from: record)
        }
    }
    
    // Добавляем метод createNewTracker
    func createNewTracker(_ tracker: Tracker) {
        var trackers: [Tracker] = []
        if let firstCategory = categories.first {
            trackers = firstCategory.trackers
        }
        trackers.append(tracker)
        
        categories = [TrackerCategory(title: "Важное", trackers: trackers)]
        trackerStore.addNewTracker(from: tracker)
        trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: "Важное")
        
        filterTrackersForCurrentDay()  // Обновляем видимые трекеры
    }
}
