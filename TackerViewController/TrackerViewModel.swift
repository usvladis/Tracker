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
        print("Loaded Trackers: \(storedTrackers)")
        let storedCategories = trackerCategoryStore.fetchAllCategories()
        print("Loaded Categories: \(storedCategories.map { $0.title })")
        let storedRecords = trackerRecordStore.fetchAllRecords()
        
        completedTrackers = storedRecords.map { TrackerRecord(trackerId: $0.trackerId, date: $0.date) }
        print("Loaded Completed Trackers: \(completedTrackers)")
        
        if !storedCategories.isEmpty {
            categories = storedCategories.compactMap { trackerCategoryStore.decodingCategory(from: $0) }
            print("Decoded Categories: \(categories)")
        } else {
            if !storedTrackers.isEmpty {
                let newCategory = TrackerCategory(title: "Default Category", trackers: storedTrackers)
                categories.append(newCategory)
            }
        }
        visibleTrackers = categories
        filterTrackersForCurrentDay()
    }
    
    func deleteOrChangeCategory(_ category: TrackerCategory) {
        loadTrackersFromCoreData() // Обновляем категории после удаления
    }
    
    func appendTrackerInVisibleTrackers(for category: TrackerCategory, weekday: Int) {
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
        
        var uniqueTrackers = [UUID: Tracker]()
        for tracker in category.trackers {
          if tracker.schedule.contains(weekDayCase) {
            uniqueTrackers[tracker.id] = tracker
          }
        }
        
        let trackers = Array(uniqueTrackers.values)
        let updatedCategory = TrackerCategory(title: category.title, trackers: trackers)
        visibleTrackers.append(category)
    }
    
    func filterTrackersForCurrentDay() {
        // Получаем текущий день недели как Int (например, 2 для понедельника)
        let currentDayOfWeekInt = Calendar.current.component(.weekday, from: selectedDate)

        // Преобразуем Int в DayOfWeek
        guard let currentDayOfWeek = DayOfWeek.from(intValue: currentDayOfWeekInt) else {
            return // Если день не распознан
        }

        // Создаем массив категорий, где трекеры фильтруются по текущему дню
        visibleTrackers = categories.compactMap { category in
            // Фильтруем трекеры в каждой категории по дням недели
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(currentDayOfWeek)
            }
            
            // Возвращаем категорию только если есть трекеры для текущего дня
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

        // Обновляем UI
        onVisibleTrackersChanged?(visibleTrackers)
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
    
    func createNewTracker(_ tracker: Tracker, _ category: String) {
        print("didCreateNewHabit asked")
        createNewTracker(tracker: tracker)

        if let _ = trackerStore.addNewTracker(from: tracker) {
          trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: category)
        } else {
          print("Failed to save tracker")
        }
        
        loadTrackersFromCoreData() 
    }
    
    func createNewTracker(tracker: Tracker) {
        var trackers: [Tracker] = []
        guard let list = categories.first else { return }
        for tracker in list.trackers {
            trackers.append(tracker)
        }
        trackers.append(tracker)
        categories = [TrackerCategory(title: list.title, trackers: trackers)]
        filterTrackersForCurrentDay()
    }
}
