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
    
    var searchText: String = "" {
        didSet {
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
            categories.append(TrackerCategory(title: localizedString(key: "noCategoriesTrackers"), trackers: allTrackers))
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
        
        // Фильтруем категории трекеров по дню недели и тексту поиска
        visibleTrackers = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let isInSearchText = searchText.isEmpty || tracker.title.lowercased().contains(searchText.lowercased())
                let isInSchedule = tracker.schedule.contains(currentDayOfWeek)
                return isInSearchText && isInSchedule
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // Фильтрация закрепленных трекеров по расписанию и поисковому запросу
        let filteredPinnedTrackers = pinnedTrackers.filter { tracker in
            let isInSearchText = searchText.isEmpty || tracker.title.lowercased().contains(searchText.lowercased())
            return isInSearchText && tracker.schedule.contains(currentDayOfWeek)
        }
        
        // Добавляем категорию с закрепленными трекерами
        if !filteredPinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: filteredPinnedTrackers)
            visibleTrackers.insert(pinnedCategory, at: 0)
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

extension TrackerViewModel {
    func showAllTrackers() {
        // Подгружаем трекеры из хранилища
        let storedTrackers = trackerStore.fetchTracker()
        
        var allTrackers = [Tracker]()
        for tracker in storedTrackers {
            allTrackers.append(tracker)
        }
        
        print("Fetched trackers: \(allTrackers.count)")
        
        guard !allTrackers.isEmpty else {
            print("No trackers found")
            return
        }
        
        // Создаем категорию для всех трекеров
        let allTrackersCategory = TrackerCategory(title: localizedString(key: "allTrackers"), trackers: allTrackers)
        
        // Обновляем видимые трекеры
        self.visibleTrackers = [allTrackersCategory]
        print("Visible trackers categories updated: \(self.visibleTrackers.count) categories")
        
        // Сообщаем о том, что видимые трекеры изменились
        onVisibleTrackersChanged?(visibleTrackers)
        
    }
    
    func filterCompletedTrackers(isCompleted: Bool) {
        // Получаем текущий день недели для выбранной даты
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate)
        
        // Преобразуем текущий день недели в наш тип DayOfWeek
        guard let currentDayOfWeek = DayOfWeek.from(intValue: selectedWeekday) else {
            print("Ошибка: не удалось определить текущий день недели")
            return
        }
        
        // Фильтруем категории и трекеры внутри них
        let filteredCategories = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                // Проверяем, активен ли трекер в выбранный день
                let isTrackerActiveToday = tracker.schedule.contains(currentDayOfWeek)
                
                // Если трекер не активен в этот день, не отображаем его
                guard isTrackerActiveToday else { return false }
                
                // Проверяем, выполнен ли трекер на выбранную дату
                let isTrackerCompleted = completedTrackers.contains { record in
                    record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                }
                
                // Возвращаем трекеры в зависимости от их состояния (выполнен/не выполнен)
                return isCompleted ? isTrackerCompleted : !isTrackerCompleted
            }
            
            // Возвращаем категорию с отфильтрованными трекерами
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // Убираем категории, в которых нет трекеров после фильтрации
        let nonEmptyCategories = filteredCategories.filter { !$0.trackers.isEmpty }
        
        // Обновляем видимые трекеры (категории)
        self.visibleTrackers = nonEmptyCategories
        onVisibleTrackersChanged?(visibleTrackers)
    }
}
