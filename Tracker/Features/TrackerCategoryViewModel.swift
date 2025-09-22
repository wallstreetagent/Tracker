//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import Foundation

final class TrackerCategoryViewModel {
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSelection: ((String) -> Void)?

    private let categoryStore: TrackerCategoryStore

    private(set) var titles: [String] = []
    private(set) var selectedTitle: String?

    init(categoryStore: TrackerCategoryStore, selectedTitle: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedTitle = selectedTitle
        self.categoryStore.onChange = { [weak self] in self?.reload() }
    }

    func viewDidLoad() { reload() }

    func numberOfRows() -> Int { titles.count }
    func title(at indexPath: IndexPath) -> String { titles[indexPath.row] }

    func select(at indexPath: IndexPath) {
        selectedTitle = titles[indexPath.row]
        if let selectedTitle { onSelection?(selectedTitle) }
        onDataChanged?()
    }

    func addCategory(title: String) {
        do {
            try categoryStore.createCategory(title: title.trimmingCharacters(in: .whitespacesAndNewlines))
            reload()
        } catch {
            onError?("Не удалось создать категорию: \(error.localizedDescription)")
        }
    }
    
    func renameCategory(at indexPath: IndexPath, to newTitle: String) {
            let old = title(at: indexPath)
            do {
                try categoryStore.rename(from: old, to: newTitle)
                if selectedTitle == old { selectedTitle = newTitle }
                reload()
            } catch {
                onError?("Не удалось переименовать категорию")
            }
        }

        func deleteCategory(at indexPath: IndexPath) {
            let t = title(at: indexPath)
            do {
                try categoryStore.delete(title: t)
                if selectedTitle == t { selectedTitle = nil }
                reload()
            } catch {
                onError?("Не удалось удалить категорию")
            }
        }

    private func reload() {
        do {
            titles = try categoryStore.fetchAllTitles()
            onDataChanged?()
        } catch {
            onError?("Не удалось загрузить категории: \(error.localizedDescription)")
        }
    }
}
