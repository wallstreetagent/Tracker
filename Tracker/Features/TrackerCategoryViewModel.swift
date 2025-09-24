//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import Foundation

final class TrackerCategoryViewModel {

    // Outputs (биндинги)
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSelection: ((String) -> Void)?

    // State
    private(set) var selectedTitle: String?
    private var items: [TrackerCategoryViewItem] = [] { didSet { onDataChanged?() } }

    // Deps
    private let categoryStore: TrackerCategoryStoring
    private let counter: TrackerCounting

    init(categoryStore: TrackerCategoryStoring,
         counter: TrackerCounting,
         selectedTitle: String? = nil) {
        self.categoryStore = categoryStore
        self.counter = counter
        self.selectedTitle = selectedTitle

        self.categoryStore.onChange = { [weak self] in self?.reload() }
    }

    // Inputs
    func viewDidLoad() { reload() }

    func reload() {
        do {
            let titles = try categoryStore.fetchAllTitles()
            let mapped: [TrackerCategoryViewItem] = try titles.map {
                TrackerCategoryViewItem(title: $0, count: try counter.count(in: $0))
            }
            items = mapped
        } catch {
            onError?("Не удалось загрузить категории: \(error.localizedDescription)")
        }
    }

    func numberOfRows() -> Int { items.count }
    func item(at indexPath: IndexPath) -> TrackerCategoryViewItem { items[indexPath.row] }
    func title(at indexPath: IndexPath) -> String { items[indexPath.row].title }

    func select(at indexPath: IndexPath) {
        selectedTitle = items[indexPath.row].title
        if let selectedTitle { onSelection?(selectedTitle) }
    }

    func addCategory(title: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        do {
            try categoryStore.createCategory(title: t)
            reload()
        } catch {
            onError?("Не удалось создать категорию: \(error.localizedDescription)")
        }
    }

    func renameCategory(at indexPath: IndexPath, to newTitle: String) {
        let old = title(at: indexPath)
        let t = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, t != old else { return }
        do {
            try categoryStore.renameCategory(oldTitle: old, newTitle: t)
            if selectedTitle == old { selectedTitle = t }
            reload()
        } catch {
            onError?("Не удалось переименовать категорию: \(error.localizedDescription)")
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        let t = title(at: indexPath)
        do {
            try categoryStore.deleteCategory(title: t)
            if selectedTitle == t { selectedTitle = nil }
            reload()
        } catch {
            onError?("Не удалось удалить категорию: \(error.localizedDescription)")
        }
    }
}
