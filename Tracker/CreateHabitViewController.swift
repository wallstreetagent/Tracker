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

    weak var delegate: CreateHabitDelegate?

    private var selectedSchedule = Set<Weekday>()
    private var selectedCategoryTitle = "Без категории"
    private var selectedEmoji = "✅"
    private var selectedColorHex = "#34C759"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Новая привычка"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let nameField: UITextField = {
        let f = UITextField()
        f.placeholder = "Введите название трекера"
        f.font = .systemFont(ofSize: 17)
        f.clearButtonMode = .whileEditing
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let rowsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var categoryRow = makeRow(title: "Категория", action: #selector(tapCategory))
    private lazy var scheduleRow = makeRow(title: "Расписание", action: #selector(tapSchedule))

    private let sep1: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Отменить", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemRed.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Создать", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemGray3
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isEnabled = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = titleLabel

        nameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)

        view.addSubview(nameContainer)
        nameContainer.addSubview(nameField)
        view.addSubview(rowsCard)
        [categoryRow, sep1, scheduleRow].forEach { rowsCard.addSubview($0) }
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            nameContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameContainer.heightAnchor.constraint(equalToConstant: 75),

            nameField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
            nameField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),

            rowsCard.topAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: 16),
            rowsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rowsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            categoryRow.leadingAnchor.constraint(equalTo: rowsCard.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: rowsCard.trailingAnchor),
            categoryRow.topAnchor.constraint(equalTo: rowsCard.topAnchor),
            categoryRow.heightAnchor.constraint(equalToConstant: 60),

            sep1.leadingAnchor.constraint(equalTo: rowsCard.leadingAnchor, constant: 16),
            sep1.trailingAnchor.constraint(equalTo: rowsCard.trailingAnchor, constant: -16),
            sep1.topAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            sep1.heightAnchor.constraint(equalToConstant: 0.5),

            scheduleRow.leadingAnchor.constraint(equalTo: rowsCard.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: rowsCard.trailingAnchor),
            scheduleRow.topAnchor.constraint(equalTo: sep1.bottomAnchor),
            scheduleRow.heightAnchor.constraint(equalToConstant: 60),
            scheduleRow.bottomAnchor.constraint(equalTo: rowsCard.bottomAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }

    @objc private func textChanged() { updateCreateState() }

    @objc private func tapCategory() {
        let alert = UIAlertController(title: "Категория", message: "Экран позже. Используем «\(selectedCategoryTitle)».", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func tapSchedule() {
        let vc = ScheduleViewController(initialSelection: selectedSchedule)
        vc.onDone = { [weak self] set in
            self?.selectedSchedule = set
            self?.scheduleRow.subtitle.text = set.isEmpty ? "" : self?.shortSchedule(set)
            self?.updateCreateState()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func cancel() { dismiss(animated: true) }

    @objc private func create() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, name.count <= 38, !selectedSchedule.isEmpty else { return }
        delegate?.createHabitDidFinish(name: name,
                                       schedule: selectedSchedule,
                                       colorHex: selectedColorHex,
                                       emoji: selectedEmoji,
                                       categoryTitle: selectedCategoryTitle)
        dismiss(animated: true)
    }

    private func updateCreateState() {
        let ok = (nameField.text?.isEmpty == false) && nameField.text!.count <= 38 && !selectedSchedule.isEmpty
        createButton.isEnabled = ok
        createButton.backgroundColor = ok ? .label : .systemGray3
    }

    private func makeRow(title: String, action: Selector) -> RowView {
        let row = RowView(title: title)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return row
    }

    private func shortSchedule(_ set: Set<Weekday>) -> String {
        if set == Set<Weekday>(Weekday.everyday) { return "Каждый день" }
        let order: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]
        let map: [Weekday: String] = [.mon:"Пн", .tue:"Вт", .wed:"Ср", .thu:"Чт", .fri:"Пт", .sat:"Сб", .sun:"Вс"]
        return order.filter { set.contains($0) }.map { map[$0]! }.joined(separator: ", ")
    }
}

final class RowView: UIView {
    let title = UILabel()
    let subtitle = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(title text: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        title.text = text
        title.font = .systemFont(ofSize: 16)
        subtitle.font = .systemFont(ofSize: 13)
        subtitle.textColor = .secondaryLabel
        chevron.tintColor = .tertiaryLabel

        [title, subtitle, chevron].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),

            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
