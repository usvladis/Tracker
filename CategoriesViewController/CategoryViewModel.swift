//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Владислав Усачев on 07.09.2024.
//

import UIKit

final class CategoryViewModel {
    private let trackerCategoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?(categories)
        }
    }

    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?

    init(store: TrackerCategoryStore) {
        self.trackerCategoryStore = store
        self.trackerCategoryStore.delegate = self
        loadCategories()
    }

    func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories().compactMap {
            trackerCategoryStore.decodingCategory(from: $0)
        }
    }
    
    func deleteCategory(at index: Int) {
        // Удаляем категорию из Core Data
        let category = categories[index]
        trackerCategoryStore.deleteCategory(category)
        NotificationCenter.default.post(name: NSNotification.Name("CategoryDeleted"), object: category)
        // Обновляем локальный массив категорий и UI
        categories.remove(at: index)
        onCategoriesChanged?(categories)
    }

    func addCategory(title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore.createCategory(newCategory)
        categories.append(newCategory)
    }

    func numberOfCategories() -> Int {
        return categories.count
    }

    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }

    func selectCategory(at index: Int) {
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateData(in store: TrackerCategoryStore) {
        loadCategories()
    }
}

