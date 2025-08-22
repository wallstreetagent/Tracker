//
//  ViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Data
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private var filteredCategories: [TrackerCategory] = []

    // Текущая выбранная дата из пикера
    private var selectedDate: Date { datePicker.date }

    // Текущий текст поиска
    private var searchText: String {
        (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.timeZone = .current
        picker.minuteInterval = 1
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let placeholderImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "placeholderStar"))
        iv.tintColor = .clear
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: view.bounds.width - 32, height: 94)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self

        // Если твоя ячейка из кода — оставь эту строку.
        // Если ячейка из storyboard/xib и у неё уже задан reuseIdentifier = "TrackerCell",
        // УДАЛИ/закомментируй следующую строку.
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")

        return cv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [titleLabel, plusButton, datePicker, searchBar, collectionView, placeholderImage, placeholderLabel]
            .forEach { view.addSubview($0) }

        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        searchBar.delegate = self

        setupConstraints()
        applyFiltersAndReload()
    }

    // MARK: - Actions

    @objc private func dateChanged(_ sender: UIDatePicker) {
        applyFiltersAndReload()
    }

    @objc private func didTapPlus() {
        let createVC = CreateHabitViewController()
        createVC.delegate = self
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    // MARK: - Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalToConstant: 44),

            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: plusButton.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 10),

            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Rendering

    private func applyFiltersAndReload() {
        // Пока без реальной фильтрации (поиск/дата) — показываем всё
        filteredCategories = categories

        updateEmptyState()
        collectionView.isHidden = filteredCategories.isEmpty
        collectionView.reloadData()
    }

    private func updateEmptyState() {
        let isEmpty = filteredCategories.isEmpty || filteredCategories.allSatisfy { $0.trackers.isEmpty }
        placeholderImage.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }

    // MARK: - Mutations

    private func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        var newCategories: [TrackerCategory] = []
        var inserted = false

        for cat in categories {
            if cat.title == title {
                let updated = TrackerCategory(title: cat.title, trackers: cat.trackers + [tracker])
                newCategories.append(updated)
                inserted = true
            } else {
                newCategories.append(cat)
            }
        }
        if !inserted {
            newCategories.append(TrackerCategory(title: title, trackers: [tracker]))
        }

        categories = newCategories
        applyFiltersAndReload()
    }

    // MARK: - Helpers

    private func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        return completedTrackers.contains {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: day)
        }
    }

    private func pluralizeDays(_ n: Int) -> String {
        switch n {
        case 0: return "0 дней"
        case 1: return "1 день"
        case 2...4: return "\(n) дня"
        default: return "\(n) дней"
        }
    }

    private func color(fromHex hex: String) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        // #RRGGBB
        if s.count == 6 {
            return UIColor(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
        // #RRGGBBAA
        if s.count == 8 {
            return UIColor(
                red: CGFloat((rgb & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgb & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgb & 0x000000FF) / 255.0
            )
        }
        return .secondarySystemBackground
    }
}

// MARK: - CreateHabitDelegate

extension TrackersViewController: CreateHabitDelegate {
    func createHabitDidFinish(name: String,
                              schedule: Set<Weekday>,
                              colorHex: String,
                              emoji: String,
                              categoryTitle: String) {
        let tracker = Tracker(name: name, colorHex: colorHex, emoji: emoji, schedule: schedule)
        addTracker(tracker, toCategoryWithTitle: categoryTitle)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]

        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let daysText = pluralizeDays(daysCount)
        let doneToday = isCompleted(trackerId: tracker.id, on: selectedDate)
        let canToggle = Calendar.current.startOfDay(for: selectedDate) <= Calendar.current.startOfDay(for: Date())

        cell.configure(
            name: tracker.name,
            emoji: tracker.emoji,
            color: color(fromHex: tracker.colorHex),
            daysText: daysText,
            isDoneToday: doneToday,
            canToggle: canToggle
        )

        return cell
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFiltersAndReload()
    }
}
