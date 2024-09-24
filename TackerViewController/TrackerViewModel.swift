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
    
    var pinnedTrackers: [Tracker] = []
    
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

        // Очищаем массив закрепленных трекеров перед его обновлением
        pinnedTrackers.removeAll()

        // Загружаем трекеры и создаем новую категорию для закрепленных
        var allTrackers = [Tracker]()
        for tracker in storedTrackers {
            if tracker.isPinned {
                // Проверяем, есть ли уже трекер в массиве pinnedTrackers, чтобы избежать дублирования
                if !pinnedTrackers.contains(where: { $0.id == tracker.id }) {
                    pinnedTrackers.append(tracker)
                }
            } else {
                allTrackers.append(tracker)
            }
        }

        if !storedCategories.isEmpty {
            categories = storedCategories.compactMap { trackerCategoryStore.decodingCategory(from: $0) }
        } else {
            categories.append(TrackerCategory(title: "Трекеры без категорий", trackers: allTrackers))
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
        let currentDayOfWeekInt = Calendar.current.component(.weekday, from: selectedDate)
        
        guard let currentDayOfWeek = DayOfWeek.from(intValue: currentDayOfWeekInt) else {
            return
        }
        
        visibleTrackers = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(currentDayOfWeek)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // Фильтруем закрепленные трекеры по расписанию
        let filteredPinnedTrackers = pinnedTrackers.filter { tracker in
            tracker.schedule.contains(currentDayOfWeek)
        }
        
        // Добавляем категорию с закрепленными трекерами только если есть трекеры на этот день
        if !filteredPinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: filteredPinnedTrackers)
            visibleTrackers.insert(pinnedCategory, at: 0) // Вставляем в начало списка
        }
        
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
        trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: category)
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
    
    func deleteTracker(tracker: Tracker) {
        print("didDeleteTracker called")
        // Удаление трекера из Core Data
        trackerStore.deleteTracker(tracker: tracker)
        trackerRecordStore.deleteAllRecordFor(tracker: tracker)
        print("Tracker successfully deleted")
        // Обновляем локальные данные
        loadTrackersFromCoreData()
    }
    
    // Метод для закрепления трекера
    func pinTracker(_ tracker: Tracker) {
        print("pinTracker called")
        trackerStore.pinOrUnpinTracker(tracker: tracker, isPinned: true)
//        if !pinnedTrackers.contains(where: { $0.id == tracker.id }) {
//            pinnedTrackers.append(tracker)
//            // Добавить в категорию "Закрепленные"
//            if let index = categories.firstIndex(where: { $0.title == "Закрепленные" }) {
//                categories[index].trackers.append(tracker)
//            }
//        }
        loadTrackersFromCoreData()
    }

    // Метод для открепления трекера
    func unpinTracker(_ tracker: Tracker) {
        print("unpinTracker called")
        trackerStore.pinOrUnpinTracker(tracker: tracker, isPinned: false)
        if let index = pinnedTrackers.firstIndex(where: { $0.id == tracker.id }) {
            pinnedTrackers.remove(at: index)
            // Удаляем из категории "Закрепленные"
            if let index = categories.firstIndex(where: { $0.title == "Закрепленные" }) {
                categories[index].trackers.removeAll(where: { $0.id == tracker.id })
            }
        }
        loadTrackersFromCoreData()
    }
    
    func updateTracker(_ tracker: Tracker, _ category: String, _ newCategory: String) {
        // Найдем индекс старой категории, к которой принадлежит трекер
        guard let indexOfOldCategory = categories.firstIndex(where: { $0.title == category }),
              let indexOfTrackerInOldCategory = categories[indexOfOldCategory].trackers.firstIndex(where: { $0.id == tracker.id })
        else {
            print("Old category or tracker not found")
            return
        }
        
        // Удаляем трекер из старой категории, но не меняем название категории
        categories[indexOfOldCategory].trackers.remove(at: indexOfTrackerInOldCategory)
        
        // Если категория изменилась
        if category != newCategory {
            // Добавляем трекер в новую категорию
            if let indexOfNewCategory = categories.firstIndex(where: { $0.title == newCategory }) {
                // Если новая категория уже существует
                categories[indexOfNewCategory].trackers.append(tracker)
            } else {
                // Если новая категория не существует, создаем новую категорию с трекером
                let newCategoryToAdd = TrackerCategory(title: newCategory, trackers: [tracker])
                categories.append(newCategoryToAdd)
            }
            
            // Обновляем трекер в Core Data
            trackerStore.updateTracker(tracker: tracker)
            trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: category)
            trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: newCategory)
            
            print("Tracker moved to a new category")
        } else {
            // Если категория не изменилась, добавляем трекер обратно в старую категорию
            categories[indexOfOldCategory].trackers.append(tracker)
            
            // Обновляем трекер в Core Data
            trackerStore.updateTracker(tracker: tracker)
            
            print("Tracker updated in the same category")
        }
        
        // Перезагружаем видимые категории и трекеры
        filterTrackersForCurrentDay()
    }
}
