//
//  ViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Deps
    private let coreDataStack: CoreDataStack
    private let provider: TrackersProvider

    init(coreDataStack: CoreDataStack, provider: TrackersProvider) {
        self.coreDataStack = coreDataStack
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - State
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedToday: Set<UUID> = []
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())

    // MARK: - UI
    private let searchField: UISearchTextField = {
        let f = UISearchTextField()
        f.placeholder = "Поиск"
        f.returnKeyType = .done
        f.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        f.layer.cornerRadius = 10
        f.layer.masksToBounds = true
        f.translatesAutoresizingMaskIntoConstraints = false
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
        l.font = .systemFont(ofSize: 12)
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
        cv.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseIdentifier
        )
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

        view.backgroundColor = .ypWhiteDay

        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        navDatePicker.date = Date()
        currentDate = Calendar.current.startOfDay(for: navDatePicker.date)

        reloadSnapshot()

        provider.onChange = { [weak self] in
            DispatchQueue.main.async { self?.reloadSnapshot() }
        }
    }

    // MARK: - UI setup
    private func configureNavBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapPlus)
        )
        addButton.tintColor = .ypBlackDay
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navDatePicker)
    }

    private func layoutUI() {
        view.addSubview(searchField)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func didTapPlus() {
        let chooser = ChooseTrackerTypeViewController()
        chooser.delegate = self
        let nav = UINavigationController(rootViewController: chooser)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        reloadSnapshot()
    }

    @objc private func searchChanged() {
        reloadSnapshot()
    }

    // MARK: - Data
    private func reloadSnapshot() {
        let query = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        categories = (try? provider.snapshot(for: currentDate, query: query)) ?? []
        filteredCategories = categories

        rebuildCompletedTodaySet()

        let isEmpty = filteredCategories.isEmpty || filteredCategories.allSatisfy { $0.trackers.isEmpty }
        placeholderImage.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty

        collectionView.reloadData()
    }

    private func rebuildCompletedTodaySet() {
        var set = Set<UUID>()
        for cat in categories {
            for t in cat.trackers {
                let done = (try? provider.isDone(trackerId: t.id, on: currentDate)) ?? false
                if done { set.insert(t.id) }
            }
        }
        completedToday = set
    }

    private func totalDays(for id: UUID) -> Int {
        (try? provider.totalDays(for: id)) ?? 0
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

    // СОЗДАНИЕ — как было
    func createHabitDidFinish(name: String,
                              schedule: Set<Weekday>,
                              colorHex: String,
                              emoji: String,
                              categoryTitle: String) {
        let tracker = Tracker(name: name, colorHex: colorHex, emoji: emoji, schedule: schedule)
        try? provider.createTracker(tracker, in: categoryTitle)
        dismiss(animated: true)
        reloadSnapshot()
    }


    func editHabitDidFinish(id: UUID,
                            name: String,
                            schedule: Set<Weekday>,
                            colorHex: String,
                            emoji: String,
                            categoryTitle: String) {
      
        try? provider.updateTracker(id: id,
                                    name: name,
                                    schedule: schedule,
                                    colorHex: colorHex,
                                    emoji: emoji,
                                    categoryTitle: categoryTitle)
        dismiss(animated: true)
        reloadSnapshot()
    }
}


// MARK: - Collection
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TrackerCellDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { filteredCategories.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCell

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let days = totalDays(for: tracker.id)
        let doneToday = completedToday.contains(tracker.id)
        let canToggle = currentDate <= Calendar.current.startOfDay(for: Date())

        cell.configure(
            name: tracker.name,
            emoji: tracker.emoji,
            color: UIColor(hex: tracker.colorHex) ?? .systemGreen,
            daysText: daysText(days),
            isDoneToday: doneToday,
            canToggle: canToggle
        )
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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontal = 16 + 16 + 9
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
        try? provider.toggleRecord(trackerId: tracker.id, on: currentDate)
        reloadSnapshot()
    }
}



// MARK: - Search delegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TrackersViewController {

    private func makeBannerPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let ns = configuration.identifier as? NSIndexPath else { return nil }
        let indexPath = ns as IndexPath

        let t = tracker(at: indexPath)
        let color = UIColor(hex: t.colorHex) ?? .systemOrange

        // делаем такую же плашку, но как UIView
        let size = TrackerContextPreviewViewController.targetSize
        let banner = UIView(frame: CGRect(origin: .zero, size: size))
        banner.backgroundColor = .clear
        let container = UIView(frame: banner.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.backgroundColor = color
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        banner.addSubview(container)

        let emoji = UILabel()
        emoji.text = t.emoji
        emoji.font = .systemFont(ofSize: 22, weight: .regular)
        emoji.setContentHuggingPriority(.required, for: .horizontal)

        let title = UILabel()
        title.text = t.name
        title.textColor = .white
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [emoji, title])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        guard let attrs = collectionView.layoutAttributesForItem(at: indexPath) else {
            return UITargetedPreview(view: banner)
        }
        let cellFrame = attrs.frame
        // позиция плашки — над карточкой; при необходимости подстрой offset
        let center = CGPoint(x: cellFrame.midX, y: cellFrame.minY + 36)

        let target = UIPreviewTarget(container: collectionView, center: center)
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        params.visiblePath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 16)

        return UITargetedPreview(view: banner, parameters: params, target: target)
    }

    // старт анимации (lift)
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeBannerPreview(for: configuration)
    }

    // завершение анимации (dismiss)
    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeBannerPreview(for: configuration)
    }
}


extension TrackersViewController {

    private func tracker(at indexPath: IndexPath) -> Tracker {
        filteredCategories[indexPath.section].trackers[indexPath.item]
    }

    private func presentEditor(for tracker: Tracker) {
        let vc = CreateHabitViewController(coreDataStack: coreDataStack)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    private func confirmDelete(tracker: Tracker, indexPath: IndexPath) {
        let ac = UIAlertController(title: "Удалить трекер?",
                                   message: "«\(tracker.name)» будет удалён.",
                                   preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            try? self?.provider.deleteTracker(id: tracker.id)
            self?.reloadSnapshot()
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = ac.popoverPresentationController,
           let cell = collectionView.cellForItem(at: indexPath) {
            pop.sourceView = cell
            pop.sourceRect = cell.bounds
        }
        present(ac, animated: true)
    }
}

// MARK: - ChooseTrackerTypeDelegate
extension TrackersViewController: ChooseTrackerTypeDelegate {
    func chooseTypeDidPick(_ type: TrackerType) {
        let vc = CreateHabitViewController(coreDataStack: coreDataStack, mode: type)
        vc.delegate = self
        (presentedViewController as? UINavigationController)?.pushViewController(vc, animated: true)
    }
}


extension TrackersViewController {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration {

        let t = tracker(at: indexPath)

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: {
                let t = self.tracker(at: indexPath)
                let color = UIColor(hex: t.colorHex) ?? .systemOrange
                let vc = TrackerContextPreviewViewController(
                    emoji: t.emoji,
                    text: t.name,
                    color: color
                )
                vc.preferredContentSize = TrackerContextPreviewViewController.targetSize
                return vc
            },

            actionProvider: { [weak self] _ in
                guard let self else { return UIMenu() }

                let pin = UIAction(title: "Закрепить") { _ in
                    try? self.provider.togglePin(id: t.id)
                    self.reloadSnapshot()
                }

                let edit = UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self else { return }
                    let t = self.tracker(at: indexPath)
                    let categoryTitle = self.filteredCategories[indexPath.section].title
                    let mode: TrackerType = t.schedule.isEmpty ? .event : .habit

                    let vc = CreateHabitViewController(coreDataStack: self.coreDataStack,
                                                       mode: mode,
                                                       editing: (tracker: t, categoryTitle: categoryTitle))
                    vc.delegate = self
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .formSheet
                    self.present(nav, animated: true)
                }

                let delete = UIAction(
                    title: "Удалить",
                    attributes: [.destructive]
                ) { _ in
                    self.confirmDelete(tracker: t, indexPath: indexPath)
                }

                return UIMenu(children: [pin, edit, delete])
            }

        )
    }
}
