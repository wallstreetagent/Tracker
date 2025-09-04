//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import UIKit

protocol CreateHabitDelegate: AnyObject {
    func createHabitDidFinish(name: String,
                              schedule: Set<Weekday>,
                              colorHex: String,
                              emoji: String,
                              categoryTitle: String)
}

final class CreateHabitViewController: UIViewController {

    // MARK: - External
    weak var delegate: CreateHabitDelegate?

    // MARK: - State
    private var selectedSchedule = Set<Weekday>()
    private var selectedCategoryTitle = "Без категории"
    private var selectedEmoji = "✅"
    private var selectedColorHex = "#34C759"
    private let nameLimit = 38

    // MARK: - UI (как в референсе)
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
        l.textColor = .systemRed            // аналог ypRed
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
        b.setTitleColor(.systemRed, for: .normal)     // аналог ypRed
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
        b.backgroundColor = .systemGray3     // аналог ypGray
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

    // переключаем верхний якорь таблицы между nameTextField и limitLabel
    private var tableTopToLabel: NSLayoutConstraint?
    private var tableTopToTextField: NSLayoutConstraint?

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never

        view.backgroundColor = .ypWhiteDay

        // Заголовок не в navigationItem.titleView — он в контенте, как в макете
        nameTextField.delegate = self

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.backgroundColor = .clear

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        layoutUI()
    }

    // MARK: - Layout (точно как в референсе)
    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // Scroll
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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

        [titleLabel, nameTextField, limitLabel, settingsTableView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        tableTopToLabel = settingsTableView.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 32)
        tableTopToTextField = settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        tableTopToTextField?.isActive = true

        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            // Поле ввода
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Лимит
            limitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Таблица настроек (категория/расписание)
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),

            // Кнопки снизу
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),

            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),

            createButton.topAnchor.constraint(greaterThanOrEqualTo: settingsTableView.bottomAnchor, constant: 24),
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
        limitLabel.isHidden = count < nameLimit  // показать при >= 38
        updateCreateButtonState()
        updateLimitLayout()
    }

    @objc private func cancel() { dismiss(animated: true) }

    @objc private func create() {
        guard isCreateButtonEnabled,
              let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, name.count <= nameLimit else { return }

        delegate?.createHabitDidFinish(name: name,
                                       schedule: selectedSchedule,
                                       colorHex: selectedColorHex,
                                       emoji: selectedEmoji,
                                       categoryTitle: selectedCategoryTitle)
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
            // экран категорий — позже
            break
        case .schedule:
            // у тебя в проекте сейчас инициализатор с initialSelection
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

        if row == .schedule, !selectedSchedule.isEmpty {
            config.secondaryText = scheduleSummary(selectedSchedule)
            config.secondaryTextProperties.color = .systemGray3
            config.secondaryTextProperties.font = .systemFont(ofSize: 17)
        }

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground

        // убираем нижний разделитель у последней
        if indexPath.row == SettingsRow.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
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

// MARK: - Support types

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
