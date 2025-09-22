//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//


import UIKit

protocol CreateHabitDelegate: AnyObject {
    func createHabitDidFinish(
        name: String,
        schedule: Set<Weekday>,
        colorHex: String,
        emoji: String,
        categoryTitle: String
    )
}

final class CreateHabitViewController: UIViewController {

    // MARK: - External
    weak var delegate: CreateHabitDelegate?

    // MARK: - Deps
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - State
    private var selectedSchedule = Set<Weekday>()
    private var selectedCategoryTitle = "Без категории"
    private var selectedEmoji = "✅"
    private var selectedColorHex = "#34C759"
    private let nameLimit = 38

    // MARK: - Data for pickers
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😴"]
    private let colorHexes = [
        "#FD3B2F","#FF8B13","#2FD2FF","#3B82F6","#8B5CF6","#10B981","#EA7CFF",
        "#FECACA","#FFD6B3","#A7F3D0","#818CF8","#FF6B57","#FFAFD1",
        "#F9D999","#A7B5FF","#A855F7","#C084FC","#22C55E"
    ]
    private var selectedEmojiIndex: IndexPath = IndexPath(item: 0, section: 0)
    private var selectedColorIndex: IndexPath = IndexPath(item: 5, section: 0) // соответствует #34C759

    // MARK: - UI (emoji/color)
    private let emojiTitle: UILabel = {
        let l = UILabel()
        l.text = "Emoji"
        l.font = .systemFont(ofSize: 19, weight: .semibold)
        return l
    }()

    private let emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    private let colorTitle: UILabel = {
        let l = UILabel()
        l.text = "Цвет"
        l.font = .systemFont(ofSize: 19, weight: .semibold)
        return l
    }()

    private let colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    // MARK: - UI (common)
    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.keyboardDismissMode = .interactive
        return v
    }()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Новая привычка"
        l.font = .systemFont(ofSize: 16)
        return l
    }()

    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.font = .systemFont(ofSize: 17)
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = .ypBackground
        tf.layer.cornerRadius = 16
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)
        return tf
    }()

    private let limitLabel: UILabel = {
        let l = UILabel()
        l.text = "Ограничение 38 символов"
        l.font = .systemFont(ofSize: 17)
        l.textColor = .systemRed
        l.isHidden = true
        return l
    }()

    private let settingsTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        tv.rowHeight = 75
        tv.layer.cornerRadius = 16
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.isScrollEnabled = false
        tv.clipsToBounds = true
        return tv
    }()

    private lazy var cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Отменить", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemRed.cgColor
        b.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return b
    }()

    private lazy var createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Создать", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.layer.cornerRadius = 16
        b.backgroundColor = .systemGray3
        b.isEnabled = false
        b.setTitleColor(.white, for: .normal)
        b.addTarget(self, action: #selector(create), for: .touchUpInside)
        return b
    }()

    private var isCreateButtonEnabled: Bool = false {
        didSet {
            createButton.isEnabled = isCreateButtonEnabled
            createButton.backgroundColor = isCreateButtonEnabled ? .ypBlackDay : .systemGray3
        }
    }

    private var tableTopToLabel: NSLayoutConstraint?
    private var tableTopToTextField: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .ypWhiteDay

        nameTextField.delegate = self

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.backgroundColor = .clear

        emojiCollection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        emojiCollection.dataSource = self
        emojiCollection.delegate = self

        colorCollection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        colorCollection.dataSource = self
        colorCollection.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        layoutUI()
    }

    // MARK: - Categories
    @objc private func openCategories() {
        let vm = TrackerCategoryViewModel(
            categoryStore: TrackerCategoryStore(stack: coreDataStack),
            selectedTitle: selectedCategoryTitle
        )
        let vc = TrackerCategoryViewController(viewModel: vm)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Layout
    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        [titleLabel, nameTextField, limitLabel, settingsTableView,
         emojiTitle, emojiCollection, colorTitle, colorCollection,
         cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        tableTopToLabel = settingsTableView.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 32)
        tableTopToTextField = settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        tableTopToTextField?.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            limitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),

            // Emoji
            emojiTitle.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 24),
            emojiTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            emojiCollection.topAnchor.constraint(equalTo: emojiTitle.bottomAnchor, constant: 12),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollection.heightAnchor.constraint(equalToConstant: 2 * 44 + 12),

            // Color
            colorTitle.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 24),
            colorTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            colorCollection.topAnchor.constraint(equalTo: colorTitle.bottomAnchor, constant: 12),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollection.heightAnchor.constraint(equalToConstant: 3 * 44 + 2 * 12),

            // Buttons
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),

            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),

            cancelButton.topAnchor.constraint(greaterThanOrEqualTo: colorCollection.bottomAnchor, constant: 24),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Helpers
    private func scheduleSummary(_ set: Set<Weekday>) -> String {
        if set.count == 7 { return "Каждый день" }
        let order: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]
        let map: [Weekday: String] = [.mon:"Пн", .tue:"Вт", .wed:"Ср", .thu:"Чт", .fri:"Пт", .sat:"Сб", .sun:"Вс"]
        return order.filter { set.contains($0) }.map { map[$0]! }.joined(separator: ", ")
    }

    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasDays = !selectedSchedule.isEmpty
        isCreateButtonEnabled = hasName && hasDays
    }

    private func updateLimitLayout() {
        let show = !limitLabel.isHidden
        tableTopToTextField?.isActive = !show
        tableTopToLabel?.isActive = show
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: - Actions
    @objc private func nameEditingChanged() {
        let count = nameTextField.text?.count ?? 0
        limitLabel.isHidden = count < nameLimit
        updateCreateButtonState()
        updateLimitLayout()
    }

    @objc private func cancel() { dismiss(animated: true) }

    @objc private func create() {
        guard isCreateButtonEnabled,
              let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, name.count <= nameLimit else { return }

        delegate?.createHabitDidFinish(
            name: name,
            schedule: selectedSchedule,
            colorHex: selectedColorHex,
            emoji: selectedEmoji,
            categoryTitle: selectedCategoryTitle
        )
        dismiss(animated: true)
    }

    @objc private func handleKeyboard(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect),
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double),
            let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt)
        else { return }

        let endInView = view.convert(endFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - endInView.origin.y)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: overlap, right: 0)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveRaw << 16),
                       animations: {
            self.scrollView.contentInset = insets
            self.scrollView.scrollIndicatorInsets = insets
        })
    }
}

// MARK: - UITableViewDelegate
extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch SettingsRow(rawValue: indexPath.row) {
        case .category:
            openCategories()

        case .schedule:
            let vc = ScheduleViewController(initialSelection: selectedSchedule)
            vc.onDone = { [weak self] set in
                guard let self else { return }
                self.selectedSchedule = set
                self.updateCreateButtonState()
                let idx = IndexPath(row: SettingsRow.schedule.rawValue, section: 0)
                self.settingsTableView.reloadRows(at: [idx], with: .none)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .none:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SettingsRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        let row = SettingsRow(rawValue: indexPath.row)

        var config = cell.defaultContentConfiguration()
        config.text = row?.title
        config.textProperties.font = .systemFont(ofSize: 17)

        if row == .category {
            config.secondaryText = selectedCategoryTitle
            config.secondaryTextProperties.color = .systemGray3
            config.secondaryTextProperties.font = .systemFont(ofSize: 17)
        }

        if row == .schedule, !selectedSchedule.isEmpty {
            config.secondaryText = scheduleSummary(selectedSchedule)
            config.secondaryTextProperties.color = .systemGray3
            config.secondaryTextProperties.font = .systemFont(ofSize: 17)
        }

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground

        // скрыть разделитель у последней
        if indexPath.row == SettingsRow.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSource
extension CreateHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollection ? emojis.count : colorHexes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as! EmojiCell
            cell.configure(emoji: emojis[indexPath.item], selected: indexPath == selectedEmojiIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as! ColorCell
            let uiColor = UIColor(hex: colorHexes[indexPath.item]) ?? .systemGreen
            cell.configure(color: uiColor, selected: indexPath == selectedColorIndex)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CreateHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollection {
            let prev = selectedEmojiIndex
            selectedEmojiIndex = indexPath
            selectedEmoji = emojis[indexPath.item]
            collectionView.reloadItems(at: [prev, indexPath])
        } else {
            let prev = selectedColorIndex
            selectedColorIndex = indexPath
            selectedColorHex = colorHexes[indexPath.item]
            collectionView.reloadItems(at: [prev, indexPath])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 12
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = floor((collectionView.bounds.width - totalSpacing) / itemsPerRow)
        return CGSize(width: width, height: 44)
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: .newlines) != nil { return false }
        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: r, with: string)
        return updated.count <= nameLimit
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Category delegate
extension CreateHabitViewController: TrackerCategoryViewControllerDelegate {
    func categoryViewController(_ vc: TrackerCategoryViewController, didPick title: String) {
        selectedCategoryTitle = title
        let idx = IndexPath(row: SettingsRow.category.rawValue, section: 0)
        settingsTableView.reloadRows(at: [idx], with: .none)
        updateCreateButtonState()
    }
}

// MARK: - Support views & types

final class CustomTextField: UITextField {
    var clearPadding: CGFloat = 12
    var textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: textInsets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: textInsets) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: textInsets) }
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        super.clearButtonRect(forBounds: bounds).offsetBy(dx: -clearPadding, dy: 0)
    }
}

private enum SettingsRow: Int, CaseIterable {
    case category, schedule
    var title: String {
        switch self {
        case .category: return "Категория"
        case .schedule: return "Расписание"
        }
    }
}

// MARK: - Cells

private final class EmojiCell: UICollectionViewCell {
    static let reuseId = "EmojiCell"

    private let label: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(emoji: String, selected: Bool) {
        label.text = emoji
        contentView.backgroundColor = selected ? UIColor(white: 0.92, alpha: 1.0) : .clear
    }
}

private final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"

    private let colorView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(color: UIColor, selected: Bool) {
        colorView.backgroundColor = color
        layer.borderWidth = selected ? 2 : 0
        layer.borderColor = selected ? UIColor.white.cgColor : UIColor.clear.cgColor
    }
}
