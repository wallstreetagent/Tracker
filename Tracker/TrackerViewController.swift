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
    private var completedToday: Set<UUID> = []
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Трекеры"
        l.font = .boldSystemFont(ofSize: 34)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
        let l = UILabel()
        l.text = "Что будем отслеживать?"
        l.textColor = .systemGray
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: view.bounds.width, height: 116)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 28)
        
        let availableWidth = view.bounds.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing
        let itemWidth = availableWidth / 2
        layout.itemSize = CGSize(width: itemWidth, height: 148)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        cv.register(TrackerSectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: TrackerSectionHeader.reuseIdentifier)
        return cv
    }()

    // Compact DatePicker в правом navbar
    private lazy var navDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.preferredDatePickerStyle = .compact
        dp.datePickerMode = .date
        dp.locale = Locale(identifier: "ru_RU")
        dp.timeZone = .current
        dp.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return dp
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(didTapPlus)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navDatePicker)

        [titleLabel, searchBar, collectionView, placeholderImage, placeholderLabel].forEach { view.addSubview($0) }
        searchBar.delegate = self

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),

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

        navDatePicker.date = Date()
        currentDate = Calendar.current.startOfDay(for: navDatePicker.date)
        rebuildCompletedTodaySet()
        applyFiltersAndReload()
    }

    // MARK: - Actions
    @objc private func didTapPlus() {
        let vc = CreateHabitViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        rebuildCompletedTodaySet()
        applyFiltersAndReload()
    }

    // MARK:
    private func applyFiltersAndReload() {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let weekday = weekdayFrom(date: currentDate)

        filteredCategories = categories.compactMap { cat in
            let trackers = cat.trackers.filter { t in
                let byDay = t.schedule.contains(weekday)
                let byText = query.isEmpty || t.name.lowercased().contains(query)
                return byDay && byText
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: cat.title, trackers: trackers)
        }

        let isEmpty = filteredCategories.isEmpty || filteredCategories.allSatisfy { $0.trackers.isEmpty }
        placeholderImage.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty

        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }

  
    private func weekdayFrom(date: Date) -> Weekday {
        let raw = Calendar.current.component(.weekday, from: date)
        return Weekday.fromCalendar(raw)
    }

    // MARK: - Completed helpers
    private func rebuildCompletedTodaySet() {
        let day = currentDate
        completedToday = Set(
            completedTrackers.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                              .map { $0.trackerId }
        )
    }

    private func toggleComplete(trackerId: UUID) {
        guard currentDate <= Calendar.current.startOfDay(for: Date()) else { return }
        if completedToday.contains(trackerId) {
            completedTrackers.removeAll {
                $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }
            completedToday.remove(trackerId)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: trackerId, date: currentDate))
            completedToday.insert(trackerId)
        }
    }

    private func totalDays(for id: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == id }.count
    }

    private func daysText(_ n: Int) -> String {
        switch n % 10 {
        case 1 where n % 100 != 11: return "\(n) день"
        case 2...4 where !(12...14).contains(n % 100): return "\(n) дня"
        default: return "\(n) дней"
        }
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

        var newCats: [TrackerCategory] = []
        var inserted = false
        for c in categories {
            if c.title == categoryTitle {
                newCats.append(TrackerCategory(title: c.title, trackers: c.trackers + [tracker]))
                inserted = true
            } else {
                newCats.append(c)
            }
        }
        if !inserted {
            newCats.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        }
        categories = newCats

        applyFiltersAndReload()
    }
}

// MARK: - Collection
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate, TrackerCellDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { filteredCategories.count }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath
        ) as! TrackerCell

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let days = totalDays(for: tracker.id)
        let doneToday = completedToday.contains(tracker.id)
        let canToggle = currentDate <= Calendar.current.startOfDay(for: Date())

        cell.configure(name: tracker.name,
                       emoji: tracker.emoji,
                       color: .fromHex(tracker.colorHex),
                       daysText: daysText(days),
                       isDoneToday: doneToday,
                       canToggle: canToggle)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeader.reuseIdentifier,
            for: indexPath
        ) as! TrackerSectionHeader
        header.configure(title: filteredCategories[indexPath.section].title)
        return header
    }


    func trackerCellDidToggle(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        toggleComplete(trackerId: tracker.id)
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - Search
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFiltersAndReload()
    }
}
