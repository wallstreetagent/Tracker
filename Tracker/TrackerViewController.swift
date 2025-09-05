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

    // MARK: - UI (как в эталоне)
    private let searchField: UISearchTextField = {
        let f = UISearchTextField()
        f.placeholder = "Поиск"
        f.returnKeyType = .done
        // светлая «капсула» как в макете
        f.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        f.layer.cornerRadius = 10
        f.layer.masksToBounds = true
        return f
    }()

    private let placeholderImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "placeholderStar"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Что будем отслеживать?"
        l.font = .systemFont(ofSize: 12)        // как в примере
        l.textAlignment = .center
        l.textColor = UIColor(hex: "#1A1B22") ?? .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.keyboardDismissMode = .onDrag
        cv.dataSource = self
        cv.delegate = self
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        cv.register(TrackerSectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: TrackerSectionHeader.reuseIdentifier)
        return cv
    }()

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

        configureNavBar()
        layoutUI()

        // поиск: реакции и скрытие клавиатуры
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        view.backgroundColor = .ypWhiteDay

        navDatePicker.date = Date()
        currentDate = Calendar.current.startOfDay(for: navDatePicker.date)
        rebuildCompletedTodaySet()
        applyFiltersAndReload()
    }

    // MARK: - NavBar & Layout
    private func configureNavBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(didTapPlus))
        addButton.tintColor = .ypBlackDay
        // лёгкий сдвиг влево как в примере
            //  addButton.imageInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        
        
        

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navDatePicker)
    }

    private func layoutUI() {
        [searchField, placeholderImage, placeholderLabel, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            // Поиск — под навбаром, отступы 16, высота 36 (как в эталоне)
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            // Плейсхолдеры по центру
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Коллекция — ниже поиска на 24, во всю ширину safe area
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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

    @objc private func searchChanged() {
        applyFiltersAndReload()
    }

    // MARK: - Filtering
    private func applyFiltersAndReload() {
        let query = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TrackerCellDelegate {

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
                       color: UIColor(hex: tracker.colorHex) ?? .systemGreen,
                       daysText: daysText(days),
                       isDoneToday: doneToday,
                       canToggle: canToggle)
        cell.delegate = self
        return cell
    }

    // Header (оставляем твой TrackerSectionHeader)
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

    // Размеры как в примере: 2 колонки, ширина = (width - 16 - 16 - 9) / 2, высота 148
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontal = 16 + 16 + 9  // left + right + interitem
        let w = (collectionView.bounds.width - CGFloat(totalHorizontal)) / 2
        return CGSize(width: floor(w), height: 148)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }

    func trackerCellDidToggle(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        toggleComplete(trackerId: tracker.id)
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - Search (UITextFieldDelegate)
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
